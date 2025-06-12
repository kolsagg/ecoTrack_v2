-- Add KDV rate to expense_items table for Turkish tax system
-- Different products have different VAT rates in Turkey: 1%, 8%, 18%, 20%

ALTER TABLE expense_items 
ADD COLUMN IF NOT EXISTS kdv_rate DECIMAL(5,2) DEFAULT 20.00;

-- Add comment to explain the column
COMMENT ON COLUMN expense_items.kdv_rate IS 'KDV (VAT) rate for this item in Turkey (1%, 10%, 20%)';

-- Add index for performance when filtering by KDV rate
CREATE INDEX IF NOT EXISTS idx_expense_items_kdv_rate ON expense_items(kdv_rate);

-- Update existing records to have 18% KDV (most common rate)
UPDATE expense_items 
SET kdv_rate = 20.00 
WHERE kdv_rate IS NULL;

-- Add constraint to ensure valid KDV rates
ALTER TABLE expense_items 
ADD CONSTRAINT chk_kdv_rate 
CHECK (kdv_rate IN (1.00, 10.00, 20.00)); 