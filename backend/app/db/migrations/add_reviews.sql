-- Add reviews table for merchant reviews (not receipt-based)
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    receipt_id UUID REFERENCES receipts(id) ON DELETE SET NULL, -- Optional: which receipt triggered the review
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    reviewer_name VARCHAR(100),
    reviewer_email VARCHAR(255),
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- Ensure one review per user per merchant
    UNIQUE(merchant_id, user_id)
);

-- Add RLS policies for reviews
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can view reviews (public)
CREATE POLICY "Anyone can view reviews"
    ON reviews FOR SELECT
    USING (true);

-- Users can create reviews for any merchant
CREATE POLICY "Anyone can create reviews"
    ON reviews FOR INSERT
    WITH CHECK (true);

-- Users can update their own reviews
CREATE POLICY "Users can update own reviews"
    ON reviews FOR UPDATE
    USING (auth.uid() = user_id OR user_id IS NULL);

-- Users can delete their own reviews
CREATE POLICY "Users can delete own reviews"
    ON reviews FOR DELETE
    USING (auth.uid() = user_id OR user_id IS NULL);

-- Add indexes for performance
CREATE INDEX idx_reviews_merchant_id ON reviews(merchant_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_receipt_id ON reviews(receipt_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- Add trigger for updated_at
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add merchant rating summary view
CREATE OR REPLACE VIEW merchant_ratings AS
SELECT 
    m.id as merchant_id,
    m.name as merchant_name,
    COALESCE(COUNT(r.id), 0) as total_reviews,
    COALESCE(ROUND(AVG(r.rating::numeric), 1), 0) as average_rating,
    COALESCE(COUNT(r.id) FILTER (WHERE r.rating = 5), 0) as five_star_count,
    COALESCE(COUNT(r.id) FILTER (WHERE r.rating = 4), 0) as four_star_count,
    COALESCE(COUNT(r.id) FILTER (WHERE r.rating = 3), 0) as three_star_count,
    COALESCE(COUNT(r.id) FILTER (WHERE r.rating = 2), 0) as two_star_count,
    COALESCE(COUNT(r.id) FILTER (WHERE r.rating = 1), 0) as one_star_count
FROM merchants m
LEFT JOIN reviews r ON m.id = r.merchant_id
GROUP BY m.id, m.name; 