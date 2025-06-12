from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from uuid import UUID

from app.core.auth import get_current_user, get_optional_current_user
from app.schemas.review import (
    ReviewCreateRequest,
    ReviewResponse,
    MerchantRatingResponse,
    MerchantReviewsResponse,
    ReviewUpdateRequest
)
from app.db.supabase_client import get_authenticated_supabase_client, get_supabase_admin_client
from supabase import Client

router = APIRouter()

@router.post("/merchants/{merchant_id}/reviews", response_model=ReviewResponse)
async def create_merchant_review(
    merchant_id: UUID,
    request: ReviewCreateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create a review for a merchant
    """
    try:
        # Check if merchant exists
        merchant_response = supabase.table("merchants").select("id, name").eq("id", str(merchant_id)).execute()
        
        if not merchant_response.data:
            raise HTTPException(status_code=404, detail="Merchant not found")
        
        # Check if user already reviewed this merchant
        existing_review = supabase.table("reviews").select("id").eq("merchant_id", str(merchant_id)).eq("user_id", current_user["id"]).execute()
        
        if existing_review.data:
            raise HTTPException(status_code=400, detail="You have already reviewed this merchant")
        
        # Create review
        review_data = {
            "merchant_id": str(merchant_id),
            "user_id": current_user["id"] if not request.is_anonymous else None,
            "receipt_id": request.receipt_id,
            "rating": request.rating,
            "comment": request.comment,
            "reviewer_name": request.reviewer_name or current_user.get("email", "Anonim Kullanıcı"),
            "reviewer_email": request.reviewer_email,
            "is_anonymous": request.is_anonymous
        }
        
        response = supabase.table("reviews").insert(review_data).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to create review")
        
        review = response.data[0]
        
        return ReviewResponse(
            id=review["id"],
            merchant_id=review["merchant_id"],
            rating=review["rating"],
            comment=review["comment"],
            reviewer_name=review["reviewer_name"],
            is_anonymous=review["is_anonymous"],
            receipt_id=review["receipt_id"],
            created_at=review["created_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create review: {str(e)}")

@router.get("/merchants/{merchant_id}/reviews", response_model=MerchantReviewsResponse)
async def get_merchant_reviews(
    merchant_id: UUID,
    limit: int = 10,
    offset: int = 0,
    current_user: Optional[dict] = Depends(get_optional_current_user),
    supabase: Client = Depends(get_supabase_admin_client)
):
    """
    Get reviews for a merchant with rating summary
    """
    try:
        # Get merchant rating summary
        rating_response = supabase.table("merchant_ratings").select("*").eq("merchant_id", str(merchant_id)).execute()
        
        if not rating_response.data:
            # Merchant exists but no reviews yet
            merchant_response = supabase.table("merchants").select("id, name").eq("id", str(merchant_id)).execute()
            if not merchant_response.data:
                raise HTTPException(status_code=404, detail="Merchant not found")
            
            merchant = merchant_response.data[0]
            merchant_rating = MerchantRatingResponse(
                merchant_id=str(merchant_id),
                merchant_name=merchant["name"],
                total_reviews=0,
                average_rating=0.0,
                rating_distribution={str(i): 0 for i in range(1, 6)}
            )
        else:
            rating_data = rating_response.data[0]
            merchant_rating = MerchantRatingResponse(
                merchant_id=str(merchant_id),
                merchant_name=rating_data["merchant_name"],
                total_reviews=rating_data["total_reviews"],
                average_rating=rating_data["average_rating"],
                rating_distribution={
                    "1": rating_data["one_star_count"],
                    "2": rating_data["two_star_count"],
                    "3": rating_data["three_star_count"],
                    "4": rating_data["four_star_count"],
                    "5": rating_data["five_star_count"]
                }
            )
        
        # Get recent reviews
        reviews_response = supabase.table("reviews").select("*").eq("merchant_id", str(merchant_id)).order("created_at", desc=True).range(offset, offset + limit - 1).execute()
        
        recent_reviews = []
        for review in reviews_response.data:
            recent_reviews.append(ReviewResponse(
                id=review["id"],
                merchant_id=review["merchant_id"],
                rating=review["rating"],
                comment=review["comment"],
                reviewer_name=review["reviewer_name"],
                is_anonymous=review["is_anonymous"],
                receipt_id=review["receipt_id"],
                created_at=review["created_at"]
            ))
        
        # Get current user's review if authenticated
        user_review = None
        if current_user:
            user_review_response = supabase.table("reviews").select("*").eq("merchant_id", str(merchant_id)).eq("user_id", current_user["id"]).execute()
            if user_review_response.data:
                review_data = user_review_response.data[0]
                user_review = ReviewResponse(
                    id=review_data["id"],
                    merchant_id=review_data["merchant_id"],
                    rating=review_data["rating"],
                    comment=review_data["comment"],
                    reviewer_name=review_data["reviewer_name"],
                    is_anonymous=review_data["is_anonymous"],
                    receipt_id=review_data["receipt_id"],
                    created_at=review_data["created_at"]
                )
        
        return MerchantReviewsResponse(
            merchant_rating=merchant_rating,
            recent_reviews=recent_reviews,
            user_review=user_review
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch merchant reviews: {str(e)}")

@router.get("/merchants/{merchant_id}/rating", response_model=MerchantRatingResponse)
async def get_merchant_rating(
    merchant_id: UUID,
    supabase: Client = Depends(get_supabase_admin_client)
):
    """
    Get merchant rating summary only
    """
    try:
        rating_response = supabase.table("merchant_ratings").select("*").eq("merchant_id", str(merchant_id)).execute()
        
        if not rating_response.data:
            # Check if merchant exists
            merchant_response = supabase.table("merchants").select("id, name").eq("id", str(merchant_id)).execute()
            if not merchant_response.data:
                raise HTTPException(status_code=404, detail="Merchant not found")
            
            merchant = merchant_response.data[0]
            return MerchantRatingResponse(
                merchant_id=str(merchant_id),
                merchant_name=merchant["name"],
                total_reviews=0,
                average_rating=0.0,
                rating_distribution={str(i): 0 for i in range(1, 6)}
            )
        
        rating_data = rating_response.data[0]
        return MerchantRatingResponse(
            merchant_id=str(merchant_id),
            merchant_name=rating_data["merchant_name"],
            total_reviews=rating_data["total_reviews"],
            average_rating=rating_data["average_rating"],
            rating_distribution={
                "1": rating_data["one_star_count"],
                "2": rating_data["two_star_count"],
                "3": rating_data["three_star_count"],
                "4": rating_data["four_star_count"],
                "5": rating_data["five_star_count"]
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch merchant rating: {str(e)}")

@router.put("/reviews/{review_id}", response_model=ReviewResponse)
async def update_review(
    review_id: UUID,
    request: ReviewUpdateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Update a review (only by the review author)
    """
    try:
        # Check if review exists and belongs to user
        review_response = supabase.table("reviews").select("*").eq("id", str(review_id)).eq("user_id", current_user["id"]).execute()
        
        if not review_response.data:
            raise HTTPException(status_code=404, detail="Review not found or you don't have permission to update it")
        
        # Update review
        update_data = {}
        if request.rating is not None:
            update_data["rating"] = request.rating
        if request.comment is not None:
            update_data["comment"] = request.comment
        
        if not update_data:
            raise HTTPException(status_code=400, detail="No fields to update")
        
        response = supabase.table("reviews").update(update_data).eq("id", str(review_id)).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to update review")
        
        review = response.data[0]
        
        return ReviewResponse(
            id=review["id"],
            merchant_id=review["merchant_id"],
            rating=review["rating"],
            comment=review["comment"],
            reviewer_name=review["reviewer_name"],
            is_anonymous=review["is_anonymous"],
            receipt_id=review["receipt_id"],
            created_at=review["created_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update review: {str(e)}")

@router.delete("/reviews/{review_id}")
async def delete_review(
    review_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Delete a review (only by the review author)
    """
    try:
        # Check if review exists and belongs to user
        review_response = supabase.table("reviews").select("id").eq("id", str(review_id)).eq("user_id", current_user["id"]).execute()
        
        if not review_response.data:
            raise HTTPException(status_code=404, detail="Review not found or you don't have permission to delete it")
        
        # Delete review
        response = supabase.table("reviews").delete().eq("id", str(review_id)).execute()
        
        return {"message": "Review deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete review: {str(e)}")

# Helper endpoint to create review from receipt (authenticated)
@router.post("/receipts/{receipt_id}/review", response_model=ReviewResponse)
async def create_review_from_receipt(
    receipt_id: UUID,
    request: ReviewCreateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create a merchant review triggered by a receipt (authenticated users)
    """
    try:
        # Get receipt and merchant info
        receipt_response = supabase.table("receipts").select("merchant_id").eq("id", str(receipt_id)).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=404, detail="Receipt not found")
        
        merchant_id = receipt_response.data[0]["merchant_id"]
        
        # Add receipt_id to request
        request.receipt_id = str(receipt_id)
        
        # Forward to merchant review creation
        return await create_merchant_review(
            merchant_id=UUID(merchant_id),
            request=request,
            current_user=current_user,
            supabase=supabase
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create review from receipt: {str(e)}")

# Anonymous review endpoint for public users
@router.post("/receipts/{receipt_id}/review/anonymous", response_model=ReviewResponse)
async def create_anonymous_review_from_receipt(
    receipt_id: UUID,
    request: ReviewCreateRequest,
    supabase: Client = Depends(get_supabase_admin_client)
):
    """
    Create an anonymous merchant review triggered by a receipt (no authentication required)
    """
    try:
        # Get receipt and merchant info using admin client
        receipt_response = supabase.table("receipts").select("merchant_id").eq("id", str(receipt_id)).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=404, detail="Receipt not found")
        
        merchant_id = receipt_response.data[0]["merchant_id"]
        
        # Check if merchant exists
        merchant_response = supabase.table("merchants").select("id, name").eq("id", merchant_id).execute()
        
        if not merchant_response.data:
            raise HTTPException(status_code=404, detail="Merchant not found")
        
        # Force anonymous review
        review_data = {
            "merchant_id": merchant_id,
            "user_id": None,  # Always null for anonymous
            "receipt_id": str(receipt_id),
            "rating": request.rating,
            "comment": request.comment,
            "reviewer_name": request.reviewer_name or "Anonim Kullanıcı",
            "reviewer_email": request.reviewer_email,
            "is_anonymous": True  # Always true
        }
        
        response = supabase.table("reviews").insert(review_data).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to create review")
        
        review = response.data[0]
        
        return ReviewResponse(
            id=review["id"],
            merchant_id=review["merchant_id"],
            rating=review["rating"],
            comment=review["comment"],
            reviewer_name=review["reviewer_name"],
            is_anonymous=review["is_anonymous"],
            receipt_id=review["receipt_id"],
            created_at=review["created_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create anonymous review: {str(e)}") 