import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/clinic_app_shell.dart';
import '../features/auth/presentation/login_page.dart';
import 'app_controller.dart';
import 'clinic_app_scope.dart';

class ClinicApp extends StatefulWidget {
  const ClinicApp({super.key});

  @override
  State<ClinicApp> createState() => _ClinicAppState();
}

class _ClinicAppState extends State<ClinicApp> {
  late final ClinicAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClinicAppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'عيادتي',
          theme: AppTheme.lightTheme,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return ClinicAppScope(
              controller: _controller,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: _controller.isLoggedIn
              ? const ClinicAppShell()
              : const LoginPage(),
        );
      },
    );
  }
}
