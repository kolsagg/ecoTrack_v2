-- Migration: Add Monthly Budget Support
-- This migration adds year and month columns to user_budgets table
-- and restructures budget_categories to reference specific monthly budgets

-- Step 1: Add year and month columns to user_budgets (only if they don't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_budgets' AND column_name = 'year') THEN
        ALTER TABLE user_budgets ADD COLUMN year SMALLINT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_budgets' AND column_name = 'month') THEN
        ALTER TABLE user_budgets ADD COLUMN month SMALLINT;
    END IF;
END $$;

-- Step 2: Drop the old unique constraint (one budget per user) if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'user_budgets_user_id_key' AND table_name = 'user_budgets') THEN
        ALTER TABLE user_budgets DROP CONSTRAINT user_budgets_user_id_key;
    END IF;
END $$;

-- Step 3: Add new unique constraint (one budget per user per month) if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'user_budgets_user_id_year_month_key' AND table_name = 'user_budgets') THEN
        ALTER TABLE user_budgets ADD CONSTRAINT user_budgets_user_id_year_month_key UNIQUE (user_id, year, month);
    END IF;
END $$;

-- Step 4: Add validation constraints for year and month if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_year_valid' AND table_name = 'user_budgets') THEN
        ALTER TABLE user_budgets ADD CONSTRAINT check_year_valid CHECK (year >= 2020 AND year <= 2100);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_month_valid' AND table_name = 'user_budgets') THEN
        ALTER TABLE user_budgets ADD CONSTRAINT check_month_valid CHECK (month >= 1 AND month <= 12);
    END IF;
END $$;

-- Step 5: Update existing data to have current year/month (if any exists)
UPDATE user_budgets 
SET year = EXTRACT(YEAR FROM created_at),
    month = EXTRACT(MONTH FROM created_at)
WHERE year IS NULL OR month IS NULL;

-- Step 6: Make year and month columns NOT NULL after updating existing data
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_budgets' AND column_name = 'year' AND is_nullable = 'YES') THEN
        ALTER TABLE user_budgets ALTER COLUMN year SET NOT NULL;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_budgets' AND column_name = 'month' AND is_nullable = 'YES') THEN
        ALTER TABLE user_budgets ALTER COLUMN month SET NOT NULL;
    END IF;
END $$;

-- Step 7: Add user_budget_id column to budget_categories if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'budget_categories' AND column_name = 'user_budget_id') THEN
        ALTER TABLE budget_categories ADD COLUMN user_budget_id UUID REFERENCES user_budgets(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Step 8: Update existing budget_categories to reference the correct user_budget
UPDATE budget_categories 
SET user_budget_id = (
    SELECT ub.id 
    FROM user_budgets ub 
    WHERE ub.user_id = budget_categories.user_id 
    LIMIT 1
)
WHERE user_budget_id IS NULL AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'budget_categories' AND column_name = 'user_id');

-- Step 9: Make user_budget_id NOT NULL after updating existing data
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'budget_categories' AND column_name = 'user_budget_id' AND is_nullable = 'YES') THEN
        ALTER TABLE budget_categories ALTER COLUMN user_budget_id SET NOT NULL;
    END IF;
END $$;

-- Step 10: Drop old RLS policies that depend on user_id BEFORE dropping the column
DROP POLICY IF EXISTS "Users can view their own budget categories" ON budget_categories;
DROP POLICY IF EXISTS "Users can insert their own budget categories" ON budget_categories;
DROP POLICY IF EXISTS "Users can update their own budget categories" ON budget_categories;
DROP POLICY IF EXISTS "Users can delete their own budget categories" ON budget_categories;

-- Step 11: Drop the old user_id column from budget_categories if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'budget_categories' AND column_name = 'user_id') THEN
        ALTER TABLE budget_categories DROP COLUMN user_id;
    END IF;
END $$;

-- Step 12: Drop old unique constraint and create new one
DO $$
BEGIN
    -- Try to drop old constraint if it exists
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'budget_categories_user_id_category_id_key' AND table_name = 'budget_categories') THEN
        ALTER TABLE budget_categories DROP CONSTRAINT budget_categories_user_id_category_id_key;
    END IF;
    
    -- Add new constraint if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'budget_categories_user_budget_id_category_id_key' AND table_name = 'budget_categories') THEN
        ALTER TABLE budget_categories ADD CONSTRAINT budget_categories_user_budget_id_category_id_key UNIQUE (user_budget_id, category_id);
    END IF;
END $$;

-- Step 13: Update indexes
DROP INDEX IF EXISTS idx_budget_categories_user_id;
DROP INDEX IF EXISTS idx_budget_categories_active;

-- Create new indexes if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_budget_categories_user_budget_id') THEN
        CREATE INDEX idx_budget_categories_user_budget_id ON budget_categories(user_budget_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_budget_categories_active') THEN
        CREATE INDEX idx_budget_categories_active ON budget_categories(user_budget_id, is_active) WHERE is_active = true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_user_budgets_year_month') THEN
        CREATE INDEX idx_user_budgets_year_month ON user_budgets(user_id, year, month);
    END IF;
END $$;

-- Step 14: Create new RLS policies that work with user_budget_id
CREATE POLICY "Users can view their own budget categories" ON budget_categories
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_budgets ub 
            WHERE ub.id = budget_categories.user_budget_id 
            AND ub.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own budget categories" ON budget_categories
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_budgets ub 
            WHERE ub.id = budget_categories.user_budget_id 
            AND ub.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own budget categories" ON budget_categories
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_budgets ub 
            WHERE ub.id = budget_categories.user_budget_id 
            AND ub.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own budget categories" ON budget_categories
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM user_budgets ub 
            WHERE ub.id = budget_categories.user_budget_id 
            AND ub.user_id = auth.uid()
        )
    );

-- Step 15: Update table comments
COMMENT ON TABLE user_budgets IS 'Stores monthly budget settings for users. Each user can have multiple budgets for different months/years';
COMMENT ON COLUMN user_budgets.year IS 'Year of the budget (e.g., 2024)';
COMMENT ON COLUMN user_budgets.month IS 'Month of the budget (1-12)';
COMMENT ON COLUMN budget_categories.user_budget_id IS 'References the specific monthly budget this category allocation belongs to'; 