import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_constants.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
