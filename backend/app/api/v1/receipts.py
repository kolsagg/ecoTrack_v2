from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import HTMLResponse
from typing import List, Optional
from uuid import UUID
from datetime import datetime
import os

from app.core.auth import get_current_user
from app.schemas.data_processing import (
    QRReceiptRequest, 
    QRReceiptResponse,
    ReceiptListResponse,
    ReceiptDetailResponse
)
from app.services.data_processor import DataProcessor
from app.services.qr_generator import QRGenerator
from app.db.supabase_client import get_authenticated_supabase_client, get_supabase_admin_client
from app.utils.kdv_calculator import KDVCalculator
from supabase import Client

router = APIRouter()
data_processor = DataProcessor()
qr_generator = QRGenerator()

@router.post("/scan", response_model=QRReceiptResponse)
async def scan_qr_receipt(
    request: QRReceiptRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Process QR code data and create receipt with expenses
    """
    try:
        # First, check if this QR code contains a receipt ID (our own generated QR)
        receipt_id = qr_generator.parse_receipt_qr(request.qr_data)
        
        if receipt_id:
            # This is our own QR code, check if user has access to this receipt
            receipt_response = supabase.table("receipts").select("*").eq("id", receipt_id).execute()
            
            if receipt_response.data:
                receipt = receipt_response.data[0]
                
                # Check if this receipt belongs to the current user
                if receipt["user_id"] == current_user["id"]:
                    # User owns this receipt, return full details
                    expenses_response = supabase.table("expenses").select("id").eq("receipt_id", receipt_id).execute()
                    expenses_count = len(expenses_response.data) if expenses_response.data else 0
                    
                    return QRReceiptResponse(
                        success=True,
                        message="Your existing receipt found from QR code",
                        receipt_id=receipt_id,
                        merchant_name=receipt["merchant_name"],
                        total_amount=receipt["total_amount"],
                        currency=receipt["currency"],
                        expenses_count=expenses_count,
                        processing_confidence=1.0  # Perfect match for our own QR
                    )
                else:
                    # Receipt exists but belongs to someone else
                    # Return basic info and suggest they can view it publicly
                    return QRReceiptResponse(
                        success=True,
                        message="Receipt found - you can view it at the public URL",
                        receipt_id=receipt_id,
                        merchant_name=receipt["merchant_name"],
                        total_amount=receipt["total_amount"],
                        currency=receipt["currency"],
                        expenses_count=0,
                        processing_confidence=1.0,
                        public_url=f"https://ecotrack.com/receipt/{receipt_id}"
                    )
            else:
                raise HTTPException(status_code=404, detail="Receipt not found for this QR code")
        
        # If not our QR code, process as new receipt
        result = await data_processor.process_qr_receipt(
            qr_data=request.qr_data,
            user_id=current_user["id"]
        )
        
        if not result["success"]:
            raise HTTPException(status_code=400, detail=f"QR processing failed: {', '.join(result['errors'])}")
        
        # Create receipt in database
        receipt_data = result["receipt_data"]
        receipt_response = supabase.table("receipts").insert(receipt_data).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=500, detail="Failed to create receipt")
        
        receipt_id = receipt_response.data[0]["id"]
        
        # Create expense summary
        expense_data = result["expense_data"]
        expense_data["receipt_id"] = receipt_id
        
        expense_response = supabase.table("expenses").insert(expense_data).execute()
        
        if not expense_response.data:
            raise HTTPException(status_code=500, detail="Failed to create expense")
        
        expense_id = expense_response.data[0]["id"]
        
        # Create expense items
        items_created = 0
        for item in result["expense_items"]:
            item["expense_id"] = expense_id
            
            # Use suggested category if available
            if item.get("suggested_category_id"):
                item["category_id"] = item["suggested_category_id"]
            
            item_response = supabase.table("expense_items").insert(item).execute()
            
            if item_response.data:
                items_created += 1
        
        return QRReceiptResponse(
            success=True,
            message=f"Receipt processed successfully with {items_created} items",
            receipt_id=receipt_id,
            merchant_name=receipt_data.get("merchant_name"),
            total_amount=receipt_data.get("total_amount"),
            currency=receipt_data.get("currency", "TRY"),
            expenses_count=items_created,
            processing_confidence=0.8  # Default confidence for QR processing
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"QR processing failed: {str(e)}")

@router.get("", response_model=List[ReceiptListResponse])
async def list_receipts(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    merchant: Optional[str] = Query(None, description="Filter by merchant name"),
    date_from: Optional[datetime] = Query(None, description="Filter from date"),
    date_to: Optional[datetime] = Query(None, description="Filter to date"),
    min_amount: Optional[float] = Query(None, description="Minimum amount filter"),
    max_amount: Optional[float] = Query(None, description="Maximum amount filter"),
    sort_by: str = Query("transaction_date", description="Sort field"),
    sort_order: str = Query("desc", pattern="^(asc|desc)$", description="Sort order"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    List user's receipts with filtering, pagination and sorting
    """
    try:
        # Build query (RLS will automatically filter by user_id)
        query = supabase.table("receipts").select("*")
        
        # Apply filters
        if merchant:
            query = query.ilike("merchant_name", f"%{merchant}%")
        
        if date_from:
            query = query.gte("transaction_date", date_from.isoformat())
        
        if date_to:
            query = query.lte("transaction_date", date_to.isoformat())
        
        if min_amount is not None:
            query = query.gte("total_amount", min_amount)
        
        if max_amount is not None:
            query = query.lte("total_amount", max_amount)
        
        # Apply sorting
        if sort_order == "desc":
            query = query.order(sort_by, desc=True)
        else:
            query = query.order(sort_by)
        
        # Apply pagination
        offset = (page - 1) * limit
        query = query.range(offset, offset + limit - 1)
        
        response = query.execute()
        
        receipts = []
        for receipt in response.data:
            receipts.append(ReceiptListResponse(
                id=receipt["id"],
                merchant_name=receipt["merchant_name"],
                transaction_date=receipt["transaction_date"],
                total_amount=receipt["total_amount"],
                currency=receipt["currency"],
                source=receipt["source"],
                created_at=receipt["created_at"]
            ))
        
        return receipts
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch receipts: {str(e)}")

@router.get("/{receipt_id}", response_model=ReceiptDetailResponse)
async def get_receipt_detail(
    receipt_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get detailed receipt information with expenses
    """
    try:
        # Get receipt
        receipt_response = supabase.table("receipts").select("*").eq("id", str(receipt_id)).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=404, detail="Receipt not found")
        
        receipt = receipt_response.data[0]
        
        # Get expense summary for this receipt
        expense_response = supabase.table("expenses").select("*").eq("receipt_id", str(receipt_id)).execute()
        
        expenses = []
        if expense_response.data:
            expense = expense_response.data[0]
            
            # Get expense items
            items_response = supabase.table("expense_items").select("""
                *,
                categories(id, name)
            """).eq("expense_id", expense["id"]).execute()
            
            expense_items = []
            for item in items_response.data:
                category_name = item.get("categories", {}).get("name") if item.get("categories") else None
                expense_items.append({
                    "id": item["id"],
                    "category_id": item["category_id"],
                    "category_name": category_name,
                    "description": item["description"],
                    "amount": item["amount"],
                    "quantity": item["quantity"],
                    "unit_price": item["unit_price"],
                    "notes": item["notes"]
                })
            
            expenses.append({
                "id": expense["id"],
                "total_amount": expense["total_amount"],
                "expense_date": expense["expense_date"],
                "notes": expense["notes"],
                "items": expense_items
            })
        
        return ReceiptDetailResponse(
            id=receipt["id"],
            merchant_name=receipt["merchant_name"],
            transaction_date=receipt["transaction_date"],
            total_amount=receipt["total_amount"],
            currency=receipt["currency"],
            source=receipt["source"],
            raw_qr_data=receipt["raw_qr_data"],
            parsed_receipt_data=receipt["parsed_receipt_data"],
            expenses=expenses,
            created_at=receipt["created_at"],
            updated_at=receipt["updated_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch receipt: {str(e)}")

@router.get("/public/{receipt_id}")
async def get_public_receipt(
    receipt_id: UUID,
    supabase: Client = Depends(get_supabase_admin_client)
):
    """
    Get public receipt information without authentication
    This endpoint is used when someone scans a QR code but is not logged in
    Returns basic receipt information for public viewing
    """
    try:
        # Get receipt using admin client but only if it's public
        receipt_response = supabase.table("receipts").select("*").eq("id", str(receipt_id)).eq("is_public", True).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=404, detail="Public receipt not found")
        
        receipt = receipt_response.data[0]
        
        # Get expense items for this receipt (for display purposes)
        expense_response = supabase.table("expenses").select("*").eq("receipt_id", str(receipt_id)).execute()
        
        items = []
        if expense_response.data:
            expense = expense_response.data[0]
            
            # Get expense items
            items_response = supabase.table("expense_items").select("""
                description,
                amount,
                quantity,
                unit_price,
                kdv_rate
            """).eq("expense_id", expense["id"]).execute()
            
            items = items_response.data if items_response.data else []
        
        # Generate QR code for this receipt
        qr_code = qr_generator.generate_receipt_qr(
            receipt_id=str(receipt_id),
            merchant_name=receipt["merchant_name"],
            total_amount=receipt["total_amount"],
            currency=receipt["currency"],
            transaction_date=datetime.fromisoformat(receipt["transaction_date"].replace('Z', '+00:00'))
        )
        
        # Return public receipt data (no sensitive user information)
        return {
            "id": receipt["id"],
            "merchant_id": receipt["merchant_id"],
            "merchant_name": receipt["merchant_name"],
            "transaction_date": receipt["transaction_date"],
            "total_amount": receipt["total_amount"],
            "currency": receipt["currency"],
            "items": items,
            "qr_code": qr_code,
            "created_at": receipt["created_at"],
            "is_public_view": True,
            "app_download_message": "Download the EcoTrack app to view this receipt in your app and track your expenses!"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch public receipt: {str(e)}")

@router.get("/receipt/{receipt_id}", response_class=HTMLResponse)
async def get_receipt_web_view(
    receipt_id: UUID,
    supabase: Client = Depends(get_supabase_admin_client)
):
    """
    Web view for receipt - serves HTML page for public receipt viewing
    This endpoint is accessed when someone visits the URL from QR code
    """
    try:
        # Get receipt using admin client but only if it's public
        receipt_response = supabase.table("receipts").select("*").eq("id", str(receipt_id)).eq("is_public", True).execute()
        
        if not receipt_response.data:
            # Return 404 HTML page
            return HTMLResponse(
                content="""
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Receipt Not Found - EcoTrack</title>
                    <style>
                        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                        .error { color: #e74c3c; }
                    </style>
                </head>
                <body>
                    <h1 class="error">Receipt Not Found</h1>
                    <p>The receipt you are looking for was not found or is no longer available.</p>
                    <a href="/">Back to Home</a>
                </body>
                </html>
                """,
                status_code=404
            )
        
        receipt = receipt_response.data[0]
        
        # Get expense items for this receipt
        expense_response = supabase.table("expenses").select("*").eq("receipt_id", str(receipt_id)).execute()
        
        items = []
        if expense_response.data:
            expense = expense_response.data[0]
            
            # Get expense items
            items_response = supabase.table("expense_items").select("""
                description,
                amount,
                quantity,
                unit_price,
                kdv_rate
            """).eq("expense_id", expense["id"]).execute()
            
            items = items_response.data if items_response.data else []
        
        # Format transaction date
        transaction_date = receipt["transaction_date"]
        try:
            dt = datetime.fromisoformat(transaction_date.replace('Z', '+00:00'))
            formatted_date = dt.strftime('%d.%m.%Y %H:%M')
        except:
            formatted_date = transaction_date
        
        # Read HTML template
        template_path = os.path.join(os.path.dirname(__file__), '..', '..', 'templates', 'receipt.html')
        
        try:
            with open(template_path, 'r', encoding='utf-8') as f:
                html_content = f.read()
        except FileNotFoundError:
            # Fallback HTML if template file not found
            html_content = f"""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>EcoTrack Digital Receipt</title>
                <style>
                    body {{ font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 20px; }}
                    .header {{ background: #4CAF50; color: white; padding: 20px; text-align: center; }}
                    .content {{ padding: 20px; }}
                    .total {{ font-size: 24px; font-weight: bold; color: #4CAF50; text-align: center; margin: 20px 0; }}
                    .qr-code {{ max-width: 200px; display: block; margin: 20px auto; }}
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>EcoTrack Digital Receipt</h1>
                </div>
                <div class="content">
                    <p><strong>Merchant:</strong> {receipt["merchant_name"]}</p>
                    <p><strong>Date:</strong> {formatted_date}</p>
                    <p><strong>Receipt ID:</strong> {str(receipt_id)[:8]}...</p>
                    <div class="total">{receipt["total_amount"]} {receipt["currency"]}</div>
                    <p style="text-align: center; margin-top: 30px;">
                        Download the EcoTrack app to view this receipt in your app!
                    </p>
                </div>
            </body>
            </html>
            """
        
        # Prepare template variables
        template_vars = {
            'merchant_name': receipt["merchant_name"] or "Demo Coffee Shop",
            'transaction_date': formatted_date,
            'formatted_date': formatted_date,
            'receipt_id': str(receipt_id),
            'total_amount': receipt["total_amount"] or 87.5,
            'currency': receipt["currency"] or "TRY",
            'items': items
        }
        
        # Replace basic template variables
        for key, value in template_vars.items():
            if key not in ['items', 'kdv_breakdown_html']:
                # Handle both {{ var }} and {{ var or "default" }} patterns
                import re
                pattern = r'\{\{\s*' + re.escape(key) + r'(?:\s+or\s+[^}]+)?\s*\}\}'
                html_content = re.sub(pattern, str(value), html_content)
        
        # Always ensure KDV breakdown is available
        kdv_breakdown_html = ""
        
        # Handle items section with proper logic
        if items and len(items) > 0:
            # Build items HTML with KDV calculations
            items_html = ""
            total_kdv_breakdown = []
            
            for item in items:
                quantity = item.get("quantity", 1)
                unit_price = item.get("unit_price")
                amount = item.get("amount", 0)
                description = item.get("description", "Item")
                kdv_rate = item.get("kdv_rate", 20.0)
                
                # Calculate KDV breakdown for this item
                kdv_breakdown = KDVCalculator.get_kdv_breakdown(amount, kdv_rate)
                total_kdv_breakdown.append({
                    'amount': amount,
                    'kdv_rate': kdv_rate
                })
                
                unit_price_html = ""
                if unit_price:
                    unit_price_html = f'<span class="item-unit-price">{unit_price:.2f} {template_vars["currency"]} / pcs</span>'
                
                kdv_info_html = ""
                if kdv_rate > 0:
                    kdv_info_html = f'<span class="item-kdv">KDV: {kdv_breakdown["kdv_amount"]:.2f} {template_vars["currency"]} ({kdv_rate:.0f}%)</span>'
                
                items_html += f"""
                <div class="item">
                    <div class="item-info">
                        <div class="item-name">{description}</div>
                        <div class="item-details">
                            {quantity} pcs
                            {unit_price_html}
                            {kdv_info_html}
                        </div>
                    </div>
                    <div class="item-price">
                        <div>{amount:.2f} {template_vars["currency"]}</div>
                    </div>
                </div>
                """
            
            # Calculate total KDV breakdown
            if total_kdv_breakdown:
                kdv_summary = KDVCalculator.calculate_mixed_kdv_total(total_kdv_breakdown)
                
                # Build KDV breakdown HTML - just show totals without rate breakdown
                kdv_breakdown_html = f"""
                <tr class="total-row">
                    <td><strong>{kdv_summary['total_kdv']:.2f} {template_vars['currency']}</strong></td>
                    <td><strong>{kdv_summary['total_without_kdv']:.2f} {template_vars['currency']}</strong></td>
                    <td><strong>{kdv_summary['total_amount']:.2f} {template_vars['currency']}</strong></td>
                </tr>
                """
                
                # Add KDV summary to template variables
                template_vars.update({
                    'total_kdv': kdv_summary['total_kdv'],
                    'total_without_kdv': kdv_summary['total_without_kdv'],
                    'kdv_breakdown_html': kdv_breakdown_html
                })
            else:
                # Default 20% KDV calculation
                total_amount = template_vars['total_amount']
                kdv_amount = (total_amount * 0.20 / 1.20)
                amount_without_kdv = total_amount / 1.20
                
                kdv_breakdown_html = f"""
                <tr class="total-row">
                    <td><strong>{kdv_amount:.2f} {template_vars['currency']}</strong></td>
                    <td><strong>{amount_without_kdv:.2f} {template_vars['currency']}</strong></td>
                    <td><strong>{total_amount:.2f} {template_vars['currency']}</strong></td>
                </tr>
                """
                
                template_vars.update({
                    'total_kdv': kdv_amount,
                    'total_without_kdv': amount_without_kdv,
                    'kdv_breakdown_html': kdv_breakdown_html
                })
            
            # Replace the items section
            items_section_pattern = r'\{% if items and items\|length > 0 %\}.*?\{% else %\}.*?\{% endif %\}'
            items_replacement = items_html
            html_content = re.sub(items_section_pattern, items_replacement, html_content, flags=re.DOTALL)
            
            # Set the KDV breakdown HTML from calculated values
            kdv_breakdown_html = template_vars.get('kdv_breakdown_html', '')
        else:
            # Use default items from template
            default_items = """
                <div class="item">
                    <div class="item-info">
                        <div class="item-name">Americano Coffee</div>
                        <div class="item-details">
                            2 pcs
                            <span class="item-unit-price">18.5 TRY / pcs</span>
                        </div>
                    </div>
                    <div class="item-price">
                        <div>37.0 TRY</div>
                    </div>
                </div>
                <div class="item">
                    <div class="item-info">
                        <div class="item-name">Croissant</div>
                        <div class="item-details">1 pcs</div>
                    </div>
                    <div class="item-price">
                        <div>25.5 TRY</div>
                    </div>
                </div>
                <div class="item">
                    <div class="item-info">
                        <div class="item-name">Service Fee</div>
                        <div class="item-details">1 pcs</div>
                    </div>
                    <div class="item-price">
                        <div>25.0 TRY</div>
                    </div>
                </div>
            """
            
            items_section_pattern = r'\{% if items and items\|length > 0 %\}.*?\{% else %\}(.*?)\{% endif %\}'
            html_content = re.sub(items_section_pattern, r'\1', html_content, flags=re.DOTALL)
            
            # For default case, calculate KDV breakdown from total amount
            total_amount = template_vars['total_amount']
            kdv_amount = (total_amount * 0.20 / 1.20)
            amount_without_kdv = total_amount / 1.20
            
            kdv_breakdown_html = f"""
            <tr class="total-row">
                <td><strong>{kdv_amount:.2f} {template_vars['currency']}</strong></td>
                <td><strong>{amount_without_kdv:.2f} {template_vars['currency']}</strong></td>
                <td><strong>{total_amount:.2f} {template_vars['currency']}</strong></td>
            </tr>
            """
        
        # Handle format filters
        import re
        
        # Replace {{ "%.2f"|format(value) }} patterns
        def format_number(match):
            try:
                format_str = match.group(1)
                value_expr = match.group(2)
                
                # Extract the actual value
                if 'total_amount' in value_expr:
                    value = template_vars['total_amount']
                elif 'or 87.5' in value_expr:
                    value = template_vars.get('total_amount', 87.5)
                else:
                    value = 0
                
                return format_str % float(value)
            except:
                return match.group(0)
        
        format_pattern = r'\{\{\s*"([^"]+)"\|format\(([^}]+)\)\s*\}\}'
        html_content = re.sub(format_pattern, format_number, html_content)
        
        # Clean up any remaining Jinja2 syntax
        html_content = re.sub(r'\{\%[^%]*\%\}', '', html_content)
        html_content = re.sub(r'\{\{[^}]*\}\}', '', html_content)
        
        # Replace KDV breakdown HTML - always replace, even if empty
        # Use regex to handle whitespace variations
        kdv_pattern = r'<tbody id="kdv-breakdown">\s*<!-- KDV breakdown will be populated by backend -->\s*</tbody>'
        html_content = re.sub(
            kdv_pattern,
            f'<tbody id="kdv-breakdown">{kdv_breakdown_html}</tbody>',
            html_content,
            flags=re.DOTALL
        )
        
        return HTMLResponse(content=html_content)
        
    except Exception as e:
        # Return error HTML page
        return HTMLResponse(
            content=f"""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Error - EcoTrack</title>
                <style>
                    body {{ font-family: Arial, sans-serif; text-align: center; padding: 50px; }}
                    .error {{ color: #e74c3c; }}
                </style>
            </head>
            <body>
                <h1 class="error">An Error Occurred</h1>
                <p>An error occurred while loading the receipt. Please try again later.</p>
                <p><small>Error: {str(e)}</small></p>
                <a href="/">Back to Home</a>
            </body>
            </html>
            """,
            status_code=500
        )