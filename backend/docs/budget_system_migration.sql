-- Budget System Migration
-- Creates tables for user budgets and category budget allocations

-- Create user_budgets table
CREATE TABLE IF NOT EXISTS user_budgets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_monthly_budget DECIMAL(12,2) NOT NULL CHECK (total_monthly_budget > 0),
    currency VARCHAR(3) DEFAULT 'TRY' NOT NULL,
    auto_allocate BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Ensure one budget per user
    UNIQUE(user_id)
);

-- Create budget_categories table
CREATE TABLE IF NOT EXISTS budget_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    monthly_limit DECIMAL(12,2) NOT NULL CHECK (monthly_limit >= 0),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Ensure one budget per user per category
    UNIQUE(user_id, category_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_budgets_user_id ON user_budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budget_categories_user_id ON budget_categories(user_id);
CREATE INDEX IF NOT EXISTS idx_budget_categories_category_id ON budget_categories(category_id);
CREATE INDEX IF NOT EXISTS idx_budget_categories_active ON budget_categories(user_id, is_active) WHERE is_active = true;

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_user_budgets_updated_at 
    BEFORE UPDATE ON user_budgets 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budget_categories_updated_at 
    BEFORE UPDATE ON budget_categories 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE user_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_categories ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_budgets
CREATE POLICY "Users can view their own budgets" ON user_budgets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own budgets" ON user_budgets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own budgets" ON user_budgets
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own budgets" ON user_budgets
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for budget_categories
CREATE POLICY "Users can view their own budget categories" ON budget_categories
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own budget categories" ON budget_categories
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own budget categories" ON budget_categories
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own budget categories" ON budget_categories
    FOR DELETE USING (auth.uid() = user_id);

-- Add comments for documentation
COMMENT ON TABLE user_budgets IS 'Stores overall monthly budget settings for users';
COMMENT ON TABLE budget_categories IS 'Stores budget allocations per category for users';

COMMENT ON COLUMN user_budgets.total_monthly_budget IS 'Total monthly budget amount in the specified currency';
COMMENT ON COLUMN user_budgets.currency IS 'Currency code (ISO 4217) for the budget';
COMMENT ON COLUMN user_budgets.auto_allocate IS 'Whether to automatically allocate budget to categories based on optimal percentages';

COMMENT ON COLUMN budget_categories.monthly_limit IS 'Monthly spending limit for this category';
COMMENT ON COLUMN budget_categories.is_active IS 'Whether this budget category is currently active';

-- Insert sample data for testing (optional - remove in production)
-- This would be handled by the application logic instead 