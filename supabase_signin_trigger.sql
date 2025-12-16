-- SQL to create user profile automatically on sign-in (if it doesn't exist)
-- Run this in your Supabase SQL Editor

-- Function to ensure user profile exists
CREATE OR REPLACE FUNCTION public.ensure_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert user profile if it doesn't exist
  INSERT INTO public.users (id, name, photo_url)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'name',
      split_part(COALESCE(NEW.email, 'user@example.com'), '@', 1),
      'User'
    ),
    COALESCE(NEW.raw_user_meta_data->>'photo_url', '')
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on INSERT (when user signs up)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.ensure_user_profile();

-- Trigger on UPDATE (when user confirms email or signs in)
-- This ensures profile exists even if signup trigger failed
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW 
  WHEN (OLD.email_confirmed_at IS DISTINCT FROM NEW.email_confirmed_at OR OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at)
  EXECUTE FUNCTION public.ensure_user_profile();

-- Alternative: Function that can be called manually or from RPC
CREATE OR REPLACE FUNCTION public.create_user_profile_if_not_exists()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_user_email text;
  v_user_name text;
BEGIN
  -- Get current authenticated user
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User must be authenticated';
  END IF;
  
  -- Check if profile already exists
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = v_user_id) THEN
    -- Get user email from auth.users
    SELECT email, raw_user_meta_data->>'name' 
    INTO v_user_email, v_user_name
    FROM auth.users 
    WHERE id = v_user_id;
    
    -- Create profile
    INSERT INTO public.users (id, name, photo_url)
    VALUES (
      v_user_id,
      COALESCE(v_user_name, split_part(COALESCE(v_user_email, 'user@example.com'), '@', 1), 'User'),
      COALESCE((SELECT raw_user_meta_data->>'photo_url' FROM auth.users WHERE id = v_user_id), '')
    );
  END IF;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile_if_not_exists() TO authenticated;

