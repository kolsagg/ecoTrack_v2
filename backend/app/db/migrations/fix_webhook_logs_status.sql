-- Fix webhook_logs status constraint to include 'pending'
-- Drop existing constraint and add new one with all status values

-- First, drop the existing check constraint
ALTER TABLE webhook_logs DROP CONSTRAINT webhook_logs_status_check;

-- Add new constraint with all required status values including 'pending'
ALTER TABLE webhook_logs ADD CONSTRAINT webhook_logs_status_check 
    CHECK (status = ANY(ARRAY['success'::text, 'failed'::text, 'retry'::text, 'pending'::text])); 