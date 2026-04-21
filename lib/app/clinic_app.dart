import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/clinic_app_shell.dart';
import '../features/auth/presentation/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/dependency_injection.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/diagnosis/presentation/cubits/diagnosis_cubit.dart';
import '../features/invoices/presentation/cubits/invoices_cubit.dart';
import '../features/laboratory/presentation/cubits/laboratory_cubit.dart';
import '../features/patients/presentation/cubits/patients_cubit.dart';
import '../features/reception/presentation/cubits/reception_cubit.dart';
import '../features/reports/presentation/cubits/reports_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ClinicApp extends StatefulWidget {
  const ClinicApp({super.key});

  @override
  State<ClinicApp> createState() => _ClinicAppState();
}

class _ClinicAppState extends State<ClinicApp> {
  final bool _isLoggedIn = Supabase.instance.client.auth.currentSession != null;

  @override
  Widget build(BuildContext context) {
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
      initialRoute: _isLoggedIn ? '/dashboard' : '/',
      routes: {
        '/': (context) => BlocProvider(
          create: (context) => sl<AuthCubit>(),
          child: const LoginPage(),
        ),
        '/dashboard': (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<PatientsCubit>()..fetchPatients()),
                BlocProvider(create: (_) => sl<ReceptionCubit>()..fetchRecords()),
                BlocProvider(create: (_) => sl<LaboratoryCubit>()..fetchOrders()),
                BlocProvider(create: (_) => sl<DiagnosisCubit>()..fetchCases()),
                BlocProvider(create: (_) => sl<InvoicesCubit>()..fetchInvoices()),
                BlocProvider(create: (_) => sl<ReportsCubit>()..fetchReports()),
              ],
              child: const ClinicAppShell(),
            ),
      },
    );
  }
}
