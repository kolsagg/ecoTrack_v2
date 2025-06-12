-- Add merchant_id to receipts table
ALTER TABLE receipts 
ADD COLUMN IF NOT EXISTS merchant_id UUID REFERENCES merchants(id);

-- Add index for merchant_id
CREATE INDEX IF NOT EXISTS idx_receipts_merchant_id ON receipts(merchant_id);

-- Update existing receipts to link with merchants based on merchant_name
-- This is a best-effort update for existing data
UPDATE receipts 
SET merchant_id = m.id 
FROM merchants m 
WHERE receipts.merchant_name = m.name 
AND receipts.merchant_id IS NULL; 