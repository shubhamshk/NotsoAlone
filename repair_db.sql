-- RUN THIS IN YOUR SUPABASE SQL EDITOR TO FIX THE JOIN ERROR

-- 1. Drop existing tables (Warning: This deletes existing match data)
DROP TABLE IF EXISTS match_participants CASCADE;
DROP TABLE IF EXISTS matches CASCADE;

-- 2. Create matches table with UUID ID
CREATE TABLE matches (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz DEFAULT now(),
  title text NOT NULL,
  sport text,
  location text,
  max_players int DEFAULT 10,
  joined_players int DEFAULT 0,
  organizer_id uuid REFERENCES auth.users(id),
  description text,
  image_url text,
  latitude float8,
  longitude float8
);

-- 3. Create match_participants table with UUID reference
CREATE TABLE match_participants (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz DEFAULT now(),
  match_id uuid REFERENCES matches(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  UNIQUE(match_id, user_id)
);

-- 4. Insert a fresh "Football" match to get you started
INSERT INTO matches (title, sport, location, max_players, joined_players)
VALUES ('Football Match', 'Soccer', 'Local Field', 12, 0);
