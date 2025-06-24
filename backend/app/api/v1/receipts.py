from fastapi import APIRouter, Depends, HTTPException, Query, Request
from fastapi.responses import HTMLResponse
from typing import List, Optional
from uuid import UUID
from datetime import datetime, timezone, timedelta
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
from app.services.ai_categorizer import ai_categorizer
from app.services.loyalty_service import LoyaltyService
from app.db.supabase_client import get_authenticated_supabase_client, get_supabase_admin_client
from app.utils.kdv_calculator import KDVCalculator
from supabase import Client

router = APIRouter()
data_processor = DataProcessor()
qr_generator = QRGenerator()
loyalty_service = LoyaltyService()

@router.post("/scan", response_model=QRReceiptResponse)
async def scan_qr_receipt(
    scan_request: QRReceiptRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Process EcoTrack QR code data for receipt claiming.
    Only accepts EcoTrack-generated receipt QR codes.
    
    Scenarios:
    1. User scans their own receipt again -> Show existing receipt details
    2. User scans unclaimed public receipt -> Claim it for the user (with AI categorization)
    3. User scans someone else's receipt -> HTTP 403 Forbidden
    4. User scans non-EcoTrack QR code -> HTTP 400 Invalid QR code
    """
    try:
        # First, check if this QR code contains a receipt ID (our own generated QR)
        receipt_id = qr_generator.parse_receipt_qr(scan_request.qr_data)
        
        if receipt_id:
            # This is our own QR code, check if user has access to this receipt
            receipt_response = supabase.table("receipts").select("*").eq("id", receipt_id).execute()
            
            if not receipt_response.data:
                raise HTTPException(status_code=404, detail="Receipt from this QR code was not found.")

            receipt = receipt_response.data[0]
            
            # Scenario 1: Receipt is already owned by the current user (Requirement 1.b)
            if receipt["user_id"] == current_user["id"]:
                expenses_response = supabase.table("expenses").select("id").eq("receipt_id", receipt_id).execute()
                expenses_count = len(expenses_response.data) if expenses_response.data else 0
                
                return QRReceiptResponse(
                    success=True,
                    message="Receipt already in your account. Showing details.",
                    receipt_id=receipt_id,
                    merchant_name=receipt["merchant_name"],
                    total_amount=receipt["total_amount"],
                    currency=receipt["currency"],
                    expenses_count=expenses_count,
                    processing_confidence=1.0,
                    public_url=None
                )
            
            # Scenario 2: Receipt is public and unclaimed (user_id is NULL)
            elif receipt["user_id"] is None and receipt.get("is_public"):
                # Check for expiration (Requirement 2.a)
                if receipt.get("expires_at"):
                    expires_at_dt = datetime.fromisoformat(receipt["expires_at"].replace('Z', '+00:00'))
                    current_time = datetime.now(timezone.utc)
                    if expires_at_dt < current_time:
                        raise HTTPException(status_code=410, detail="This QR code has expired and can no longer be claimed.")
                
                # Claim the receipt for the current user
                update_response = supabase.table("receipts").update({
                    "user_id": current_user["id"],
                    "is_public": False,
                    "expires_at": None  # Make it permanent
                }).eq("id", receipt_id).execute()
                
                if not update_response.data:
                    raise HTTPException(status_code=500, detail="Failed to claim the receipt.")
                
                # Also update the associated expense and expense_items to belong to the user
                supabase.table("expenses").update({
                    "user_id": current_user["id"]
                }).eq("receipt_id", receipt_id).execute()
                
                # Get expense items for AI categorization
                expenses_response = supabase.table("expenses").select("id").eq("receipt_id", receipt_id).execute()
                
                # Update expense_items user_id as well
                if expenses_response.data:
                    expense_id = expenses_response.data[0]["id"]
                    supabase.table("expense_items").update({
                        "user_id": current_user["id"]
                    }).eq("expense_id", expense_id).execute()
                expenses_count = len(expenses_response.data) if expenses_response.data else 0
                
                # Apply AI categorization to uncategorized expense items
                if expenses_response.data:
                    expense_id = expenses_response.data[0]["id"]
                    
                    # Get expense items that don't have categories assigned
                    expense_items_response = supabase.table("expense_items").select("*").eq("expense_id", expense_id).is_("category_id", "null").execute()
                    
                    if expense_items_response.data:
                        for item in expense_items_response.data:
                            try:
                                # Use AI categorizer to get category suggestion
                                categorization_result = await ai_categorizer.categorize_expense(
                                    description=item.get("description", ""),
                                    merchant_name=receipt["merchant_name"],
                                    amount=item.get("amount")
                                )
                                
                                # Only assign category if confidence is above threshold (0.3)
                                if categorization_result["confidence"] > 0.3:
                                    # Get category_id from categories table
                                    category_response = supabase.table("categories").select("id").eq("name", categorization_result["category_name"]).execute()
                                    
                                    if category_response.data:
                                        category_id = category_response.data[0]["id"]
                                        
                                        # Update expense item with category
                                        supabase.table("expense_items").update({
                                            "category_id": category_id
                                        }).eq("id", item["id"]).execute()
                                        
                            except Exception as e:
                                # Log error but don't fail the claim process
                                print(f"AI categorization failed for item {item.get('id')}: {str(e)}")
                                continue

                # Award loyalty points for the claimed receipt
                if expenses_response.data:
                    expense_id = expenses_response.data[0]["id"]
                    
                    try:
                        # Get the primary category from expense items for loyalty calculation
                        primary_category = None
                        expense_items_response = supabase.table("expense_items").select("""
                            *,
                            categories(name)
                        """).eq("expense_id", expense_id).execute()
                        
                        if expense_items_response.data:
                            # Find the first item with a category or highest value item
                            categorized_items = [item for item in expense_items_response.data if item.get("categories")]
                            if categorized_items:
                                primary_category = categorized_items[0]["categories"]["name"]
                        
                        # Award loyalty points
                        loyalty_result = await loyalty_service.award_points_for_expense(
                            user_id=current_user["id"],
                            expense_id=expense_id,
                            amount=receipt["total_amount"],
                            category=primary_category,
                            merchant_name=receipt["merchant_name"]
                        )
                        
                        if loyalty_result["success"]:
                            print(f"Loyalty points awarded on receipt claim: {loyalty_result['points_awarded']} points for user {current_user['id']}")
                        else:
                            print(f"Failed to award loyalty points for claimed receipt {receipt_id}")
                            
                    except Exception as loyalty_error:
                        # Don't fail the claim process if loyalty points fail
                        print(f"Loyalty points error during receipt claim: {str(loyalty_error)}")

                return QRReceiptResponse(
                    success=True,
                    message="Receipt successfully claimed and added to your account.",
                    receipt_id=receipt_id,
                    merchant_name=receipt["merchant_name"],
                    total_amount=receipt["total_amount"],
                    currency=receipt["currency"],
                    expenses_count=expenses_count,
                    processing_confidence=1.0,
                    public_url=None
                )

            # Scenario 3: Receipt is owned by someone else (already claimed)
            else:
                raise HTTPException(
                    status_code=403, 
                    detail="This receipt has already been claimed by another user and is no longer available."
                )
        
        # If not our QR code, reject it
        else:
            raise HTTPException(
                status_code=400, 
                detail="Invalid QR code. Only EcoTrack receipt QR codes can be scanned."
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
        # Build query with explicit user_id filter (don't rely only on RLS)
        query = supabase.table("receipts").select("*").eq("user_id", current_user["id"])
        
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

@router.get("/public/{receipt_id}", response_class=HTMLResponse)
async def get_public_receipt(
    receipt_id: UUID,
    supabase: Client = Depends(get_supabase_admin_client)
):
    """
    Public web view for receipt - serves HTML page for public receipt viewing
    This endpoint is accessed when someone visits the URL from QR code
    Includes expiration checking (Requirement 2.a)
    """
    try:
        # Get receipt using admin client but only if it's public
        receipt_response = supabase.table("receipts").select("*").eq("id", str(receipt_id)).eq("is_public", True).execute()
        
        if not receipt_response.data:
            # Return 404 HTML page if not found or already claimed
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
                    <p>The receipt you are looking for was not found, may have been claimed by a user, or is no longer available.</p>
                    <a href="/">Back to Home</a>
                </body>
                </html>
                """,
                status_code=404
            )
        
        receipt = receipt_response.data[0]

        # Requirement 2.a: Check for expiration
        if receipt.get("expires_at"):
            expires_at_dt = datetime.fromisoformat(receipt["expires_at"].replace('Z', '+00:00'))
            current_time = datetime.now(timezone.utc)
            if expires_at_dt < current_time:
                return HTMLResponse(
                    content="""
                    <!DOCTYPE html>
                    <html lang="en">
                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>QR Code Expired - EcoTrack</title>
                        <style>
                            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                            .error { color: #f39c12; }
                            .container { max-width: 500px; margin: 0 auto; }
                        </style>
                    </head>
                    <body>
                        <div class="container">
                            <h1 class="error">QR Code Expired</h1>
                            <p>The QR code you scanned has expired and is no longer valid.</p>
                            <p>Public receipts expire after 48 hours if not claimed by a user.</p>
                            <a href="/">Back to Home</a>
                        </div>
                    </body>
                    </html>
                    """,
                    status_code=410
                )
        
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

# Merchant endpoints are now handled by the webhook service at /api/v1/webhooks/merchant/{merchant_id}/transaction