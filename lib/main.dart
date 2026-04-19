import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/clinic_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const ClinicApp());
}
