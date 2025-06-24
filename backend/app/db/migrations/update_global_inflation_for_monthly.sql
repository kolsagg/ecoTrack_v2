-- Update global_product_inflation table for monthly inflation tracking
-- This migration adds columns for year/month tracking and changes the approach

-- First, backup existing data (optional but recommended)
-- CREATE TABLE global_product_inflation_backup AS SELECT * FROM global_product_inflation;

-- Drop the old table and recreate with new structure
DROP TABLE IF EXISTS public.global_product_inflation;

CREATE TABLE public.global_product_inflation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_name TEXT NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    average_price NUMERIC(10, 2) NOT NULL,
    purchase_count INTEGER NOT NULL,
    previous_month_price NUMERIC(10, 2),
    inflation_percentage NUMERIC(10, 4),
    last_updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Unique constraint for product per month
    CONSTRAINT unique_product_month UNIQUE (product_name, year, month)
);

-- Add indexes for better query performance
CREATE INDEX idx_product_inflation_date ON public.global_product_inflation (year, month);
CREATE INDEX idx_product_inflation_name ON public.global_product_inflation (product_name);
CREATE INDEX idx_product_inflation_percentage ON public.global_product_inflation (inflation_percentage);

-- Add comments to describe the new structure
COMMENT ON TABLE public.global_product_inflation IS 'Stores monthly inflation data for products across all users. Each row represents one product in one specific month.';
COMMENT ON COLUMN public.global_product_inflation.average_price IS 'Average price of the product in this specific month.';
COMMENT ON COLUMN public.global_product_inflation.previous_month_price IS 'Average price of the product in the previous month (for reference).';
COMMENT ON COLUMN public.global_product_inflation.inflation_percentage IS 'Month-over-month inflation percentage compared to previous month.';

-- Enable Row Level Security
ALTER TABLE public.global_product_inflation ENABLE ROW LEVEL SECURITY;

-- Create policies for access (same as before - public read for authenticated users)
CREATE POLICY "Allow authenticated read access"
ON public.global_product_inflation
FOR SELECT
TO authenticated
USING (true); 