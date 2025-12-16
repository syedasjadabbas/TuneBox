import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl =
      'https://crorwhvsupuqmspdpezs.supabase.co';

  // NOTE: This is your public anon key. It is safe to use in the client app.
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyb3J3aHZzdXB1cW1zcGRwZXpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTQ4MDQsImV4cCI6MjA4MTQ3MDgwNH0.dko_aXChgFWRXifbFfiDKBAkM_biSzmT0J623dyebcA';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }
}


