-- Add missing columns to the 'matches' table
-- Run this in your Supabase SQL Editor

ALTER TABLE matches 
ADD COLUMN IF NOT EXISTS event_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS latitude FLOAT8,
ADD COLUMN IF NOT EXISTS longitude FLOAT8,
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Refresh schema cache (optional but recommended)
NOTIFY pgrst, 'reload schema';
