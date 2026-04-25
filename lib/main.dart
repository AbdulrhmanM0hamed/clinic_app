import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/clinic_app.dart';

import 'core/di/dependency_injection.dart' as di;
import 'core/network/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await SupabaseConfig.initialize();

  // 3. Initialize Dependency Injection Container
  await di.init();

  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const ClinicApp());
  //build web app
  //flutter build web --no-tree-shake-icons
}
