import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient supabase = Supabase.instance.client;
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://fkvwigxbitnqtptlkhfo.supabase.co',
      publishableKey: 'sb_publishable_yEb1zqDBSkzbU8_9FeSQgQ_myLqUzQP',
    );
  }
}
