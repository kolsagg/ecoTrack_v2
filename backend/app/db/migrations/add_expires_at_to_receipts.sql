-- Add expires_at column to receipts table for public receipt expiration
-- This enables automatic cleanup of expired public receipts

-- Add expires_at column
ALTER TABLE receipts 
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Add index for efficient expired receipt queries
CREATE INDEX IF NOT EXISTS idx_receipts_expires_at ON receipts(expires_at);

-- Add index for public receipt cleanup queries
CREATE INDEX IF NOT EXISTS idx_receipts_public_expired ON receipts(is_public, expires_at) 
WHERE is_public = true AND expires_at IS NOT NULL;

-- Add comment for documentation
COMMENT ON COLUMN receipts.expires_at IS 'Expiration time for public receipts. NULL for user receipts (permanent), timestamp for public receipts that expire after 48 hours'; 