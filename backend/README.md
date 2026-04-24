# Supabase Setup Instructions

## Important: Disable Email Confirmation for Testing

To allow users to sign up and immediately use the app without email confirmation:

1. Go to your Supabase Dashboard: https://supabase.com/dashboard/project/crorwhvsupuqmspdpezs
2. Navigate to **Authentication** → **Providers** → **Email**
3. **Disable "Confirm email"** toggle
4. Save changes

This will allow users to sign up and be automatically signed in.

## Run Database Trigger (Optional but Recommended)

1. Go to **SQL Editor** in Supabase Dashboard
2. Copy and paste the contents of the files in `backend/supabase/migrations/`
3. Click **Run**
4. This will automatically create user profiles when users sign up

## Verify Tables Exist

Make sure these tables exist in your `public` schema:
- `users`
- `playlists`
- `playlist_songs`
- `favorites`

All tables should have RLS (Row Level Security) enabled with the policies we created earlier.
