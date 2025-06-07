-- Create a function to handle user deletion
CREATE OR REPLACE FUNCTION public.handle_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete from public.users table (if exists)
  DELETE FROM public.users WHERE id = OLD.id;
  
  -- You can add more delete statements here for other tables
  -- that have user data
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to automatically handle user deletion
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
CREATE TRIGGER on_auth_user_deleted
  AFTER DELETE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_user_deletion();

-- Enable RLS on users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policy for users to delete their own data
CREATE POLICY "Users can delete their own data" ON public.users
    FOR DELETE
    USING (auth.uid() = id);

-- Add cascade delete policies to related tables
ALTER TABLE public.users
  DROP CONSTRAINT IF EXISTS users_id_fkey,
  ADD CONSTRAINT users_id_fkey
    FOREIGN KEY (id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;

-- You can add more ALTER TABLE statements here for other tables
-- that should cascade delete when a user is deleted 

-- Example: If you have a user_preferences table
-- CREATE TABLE IF NOT EXISTS public.user_preferences (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
--     preference_key TEXT NOT NULL,
--     preference_value JSONB,
--     created_at TIMESTAMPTZ DEFAULT NOW(),
--     updated_at TIMESTAMPTZ DEFAULT NOW()
-- );

-- Enable RLS on user_preferences table
-- ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Create policy for users to delete their own preferences
-- CREATE POLICY "Users can delete their own preferences" ON public.user_preferences
--     FOR DELETE
--     USING (auth.uid() = user_id); 