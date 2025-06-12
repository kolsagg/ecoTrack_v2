-- Restructure expenses table to match new API design
-- This migration transforms the old single-table approach to the new container + items approach

-- First, create the new expense_items table if it doesn't exist
CREATE TABLE IF NOT EXISTS expense_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_id UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id),
    description TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(10, 2),
    kdv_rate DECIMAL(5,2) DEFAULT 20.00,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Add indexes for expense_items
CREATE INDEX IF NOT EXISTS idx_expense_items_expense_id ON expense_items(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_items_user_id ON expense_items(user_id);
CREATE INDEX IF NOT EXISTS idx_expense_items_category_id ON expense_items(category_id);

-- Add RLS policies for expense_items
ALTER TABLE expense_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own expense items"
    ON expense_items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own expense items"
    ON expense_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expense items"
    ON expense_items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expense items"
    ON expense_items FOR DELETE
    USING (auth.uid() = user_id);

-- Migrate existing expense data to the new structure
-- For each existing expense, create a corresponding expense_item
INSERT INTO expense_items (expense_id, user_id, category_id, description, amount, quantity, unit_price, notes, created_at, updated_at)
SELECT 
    id as expense_id,
    user_id,
    category_id,
    description,
    amount,
    quantity,
    CASE 
        WHEN quantity > 0 THEN amount / quantity 
        ELSE amount 
    END as unit_price,
    notes,
    created_at,
    updated_at
FROM expenses
WHERE NOT EXISTS (
    SELECT 1 FROM expense_items WHERE expense_items.expense_id = expenses.id
);

-- Now restructure the expenses table to be a container/summary table
-- Add total_amount column if it doesn't exist
ALTER TABLE expenses 
ADD COLUMN IF NOT EXISTS total_amount NUMERIC(10, 2);

-- Update total_amount for existing expenses
UPDATE expenses 
SET total_amount = amount 
WHERE total_amount IS NULL;

-- Make total_amount NOT NULL
ALTER TABLE expenses 
ALTER COLUMN total_amount SET NOT NULL;

-- Remove old columns that are now in expense_items
ALTER TABLE expenses 
DROP COLUMN IF EXISTS category_id,
DROP COLUMN IF EXISTS description,
DROP COLUMN IF EXISTS amount,
DROP COLUMN IF EXISTS quantity;

-- Add trigger for expense_items updated_at
CREATE TRIGGER update_expense_items_updated_at
    BEFORE UPDATE ON expense_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add constraint for valid KDV rates
ALTER TABLE expense_items 
ADD CONSTRAINT IF NOT EXISTS chk_kdv_rate 
CHECK (kdv_rate IN (1.00, 10.00, 20.00));

-- Add comment for documentation
COMMENT ON TABLE expense_items IS 'Individual items within an expense - contains the actual purchase details';
COMMENT ON TABLE expenses IS 'Expense container/summary - aggregates expense_items and links to receipts';
COMMENT ON COLUMN expense_items.kdv_rate IS 'KDV (VAT) rate for this item in Turkey (1%, 10%, 20%)';
COMMENT ON COLUMN expenses.total_amount IS 'Total amount of all items in this expense'; 