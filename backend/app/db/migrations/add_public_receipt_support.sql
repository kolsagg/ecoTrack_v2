-- Add support for public receipts (unregistered customers)
-- This migration adds columns needed for webhook public receipts

-- Add new column to receipts table
ALTER TABLE receipts 
ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT FALSE;

-- Allow user_id to be nullable for public receipts
ALTER TABLE receipts 
ALTER COLUMN user_id DROP NOT NULL;

-- Add index for public receipt queries
CREATE INDEX IF NOT EXISTS idx_receipts_is_public ON receipts(is_public);

-- Update RLS policies to handle public receipts
-- Drop existing policies first
DROP POLICY IF EXISTS "Users can view own receipts" ON receipts;
DROP POLICY IF EXISTS "Users can create own receipts" ON receipts;
DROP POLICY IF EXISTS "Users can update own receipts" ON receipts;
DROP POLICY IF EXISTS "Users can delete own receipts" ON receipts;

-- Create new policies that handle both user receipts and public receipts
CREATE POLICY "Users can view own receipts and public receipts"
    ON receipts FOR SELECT
    USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Users can create own receipts"
    ON receipts FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update own receipts"
    ON receipts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own receipts"
    ON receipts FOR DELETE
    USING (auth.uid() = user_id);

-- Allow service role to create/update public receipts (for webhooks)
CREATE POLICY "Service role can manage public receipts"
    ON receipts FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Add comment for documentation
COMMENT ON COLUMN receipts.is_public IS 'True for receipts created for unregistered customers via webhooks - viewable on web'; 