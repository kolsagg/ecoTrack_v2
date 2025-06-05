-- Enable RLS on users table if not already enabled
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy for users to delete their own account
CREATE POLICY "Users can delete their own account"
ON users
FOR DELETE
USING (
    auth.uid() = id -- Only allow deletion if the authenticated user's ID matches the row ID
);

-- Create policy for users to view their own account
CREATE POLICY "Users can view their own account"
ON users
FOR SELECT
USING (
    auth.uid() = id -- Only allow viewing if the authenticated user's ID matches the row ID
);

-- Create policy for users to update their own account
CREATE POLICY "Users can update their own account"
ON users
FOR UPDATE
USING (
    auth.uid() = id -- Only allow updates if the authenticated user's ID matches the row ID
)
WITH CHECK (
    auth.uid() = id -- Additional check for UPDATE operations
);

-- Add cascade delete trigger for user data cleanup
CREATE OR REPLACE FUNCTION public.handle_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete related records from other tables
    DELETE FROM expenses WHERE user_id = OLD.id;
    DELETE FROM receipts WHERE user_id = OLD.id;
    DELETE FROM categories WHERE user_id = OLD.id;
    DELETE FROM loyalty_status WHERE user_id = OLD.id;
    DELETE FROM ai_suggestions WHERE user_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_user_deletion
    BEFORE DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION handle_user_deletion(); 