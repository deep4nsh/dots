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
    print("✅ Supabase Initialized");
  }

  /* 
  SQL TO RUN IN SUPABASE SQL EDITOR:
  
  -- Add user_id column to notes table
  ALTER TABLE notes ADD COLUMN user_id UUID REFERENCES auth.users(id);

  -- Enable RLS
  ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

  -- Create policy to allow users to see only their own notes
  CREATE POLICY "Users can only access their own notes" ON notes
  FOR ALL USING (auth.uid() = user_id);
  */
}
