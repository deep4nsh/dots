import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception('❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    // debugPrint("✅ Supabase Initialized");
  }

  /* 
  SQL TO RUN IN SUPABASE SQL EDITOR:
  
  -- Create notes table
  CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    summary TEXT,
    mood TEXT,
    keywords TEXT[],
    action_items TEXT[],
    emotional_intensity INT,
    subconscious_drivers TEXT,
    cognitive_distortions TEXT[],
    core_values TEXT[],
    impact_areas TEXT[],
    sentiment_score FLOAT,
    reflection_question TEXT,
    voice_url TEXT,
    image_url TEXT,
    video_url TEXT,
    link_url TEXT,
    is_scan BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
  );

  -- Add user_id column if not exists (for existing tables)
  ALTER TABLE notes ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

  -- Add multimedia and analysis columns if not exists
  ALTER TABLE notes 
  ADD COLUMN IF NOT EXISTS summary TEXT,
  ADD COLUMN IF NOT EXISTS mood TEXT,
  ADD COLUMN IF NOT EXISTS keywords TEXT[],
  ADD COLUMN IF NOT EXISTS action_items TEXT[],
  ADD COLUMN IF NOT EXISTS emotional_intensity INT,
  ADD COLUMN IF NOT EXISTS subconscious_drivers TEXT,
  ADD COLUMN IF NOT EXISTS cognitive_distortions TEXT[],
  ADD COLUMN IF NOT EXISTS core_values TEXT[],
  ADD COLUMN IF NOT EXISTS impact_areas TEXT[],
  ADD COLUMN IF NOT EXISTS sentiment_score FLOAT,
  ADD COLUMN IF NOT EXISTS reflection_question TEXT,
  ADD COLUMN IF NOT EXISTS voice_url TEXT,
  ADD COLUMN IF NOT EXISTS image_url TEXT,
  ADD COLUMN IF NOT EXISTS video_url TEXT,
  ADD COLUMN IF NOT EXISTS link_url TEXT,
  ADD COLUMN IF NOT EXISTS is_scan BOOLEAN DEFAULT FALSE;

  -- Enable RLS
  ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

  -- Create policy to allow users to see only their own notes
  DROP POLICY IF EXISTS "Users can only access their own notes" ON notes;
  CREATE POLICY "Users can only access their own notes" ON notes
  FOR ALL USING (auth.uid() = user_id);

  -- Function to allow users to delete their own account
  CREATE OR REPLACE FUNCTION delete_user()
  RETURNS void AS $$
  BEGIN
    DELETE FROM auth.users WHERE id = auth.uid();
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;
  */
}
