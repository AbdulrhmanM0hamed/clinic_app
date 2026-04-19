import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:clinic_app/app/clinic_app.dart';

void main() {
  testWidgets('shows login screen on launch', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const ClinicApp());
    await tester.pumpAndSettle();

    expect(find.text('تسجيل دخول الطبيب'), findsOneWidget);
    expect(find.text('الدخول إلى النظام'), findsOneWidget);
  });
}
