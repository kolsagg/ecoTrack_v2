from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class ReviewCreateRequest(BaseModel):
    """Request schema for creating a merchant review"""
    rating: int = Field(..., ge=1, le=5, description="Rating from 1 to 5 stars")
    comment: Optional[str] = Field(None, max_length=500, description="Review comment")
    reviewer_name: Optional[str] = Field(None, max_length=100, description="Reviewer name (for anonymous reviews)")
    reviewer_email: Optional[str] = Field(None, max_length=255, description="Reviewer email (for anonymous reviews)")
    is_anonymous: bool = Field(False, description="Whether this is an anonymous review")
    receipt_id: Optional[str] = Field(None, description="Receipt ID that triggered this review (optional)")

    @validator('comment')
    def validate_comment(cls, v):
        if v is not None:
            v = v.strip()
            if len(v) == 0:
                return None
        return v

class ReviewResponse(BaseModel):
    """Response schema for review"""
    id: str = Field(..., description="Review ID")
    merchant_id: str = Field(..., description="Merchant ID")
    rating: int = Field(..., description="Rating from 1 to 5")
    comment: Optional[str] = Field(None, description="Review comment")
    reviewer_name: Optional[str] = Field(None, description="Reviewer name")
    is_anonymous: bool = Field(..., description="Is anonymous review")
    receipt_id: Optional[str] = Field(None, description="Receipt ID that triggered this review")
    created_at: datetime = Field(..., description="Creation date")

class MerchantRatingResponse(BaseModel):
    """Response schema for merchant rating summary"""
    merchant_id: str = Field(..., description="Merchant ID")
    merchant_name: str = Field(..., description="Merchant name")
    total_reviews: int = Field(..., description="Total number of reviews")
    average_rating: float = Field(..., description="Average rating")
    rating_distribution: dict = Field(..., description="Distribution of ratings (1-5)")

class MerchantReviewsResponse(BaseModel):
    """Response schema for merchant reviews with stats"""
    merchant_rating: MerchantRatingResponse = Field(..., description="Merchant rating summary")
    recent_reviews: List[ReviewResponse] = Field(default_factory=list, description="Recent reviews")
    user_review: Optional[ReviewResponse] = Field(None, description="Current user's review if exists")

class ReviewUpdateRequest(BaseModel):
    """Request schema for updating a review"""
    rating: Optional[int] = Field(None, ge=1, le=5, description="Updated rating")
    comment: Optional[str] = Field(None, max_length=500, description="Updated comment")

    @validator('comment')
    def validate_comment(cls, v):
        if v is not None:
            v = v.strip()
            if len(v) == 0:
                return None
        return v 