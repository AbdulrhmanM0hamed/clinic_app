import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_config.dart';

// Repos
import '../../features/patients/data/repo/patients_repo.dart';
import '../../features/reception/data/repo/reception_repo.dart';
import '../../features/laboratory/data/repo/laboratory_repo.dart';
import '../../features/diagnosis/data/repo/diagnosis_repo.dart';
import '../../features/invoices/data/repo/invoices_repo.dart';
import '../../features/auth/data/repo/auth_repo.dart';

// Cubits
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/patients/presentation/cubits/patients_cubit.dart';
import '../../features/reception/presentation/cubits/reception_cubit.dart';
import '../../features/laboratory/presentation/cubits/laboratory_cubit.dart';
import '../../features/diagnosis/presentation/cubits/diagnosis_cubit.dart';
import '../../features/invoices/presentation/cubits/invoices_cubit.dart';
import '../../features/reports/presentation/cubits/reports_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. External dependencies
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseConfig.client);

  // 2. Repositories
  sl.registerLazySingleton<PatientsRepo>(() => PatientsRepoImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton<ReceptionRepo>(() => ReceptionRepoImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton<LaboratoryRepo>(() => LaboratoryRepoImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton<DiagnosisRepo>(() => DiagnosisRepoImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton<InvoicesRepo>(() => InvoicesRepoImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl<SupabaseClient>()));

  // 3. Cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthRepo>()));
  sl.registerFactory<PatientsCubit>(() => PatientsCubit(sl<PatientsRepo>()));
  sl.registerFactory<ReceptionCubit>(() => ReceptionCubit(
        sl<ReceptionRepo>(),
        sl<PatientsRepo>(),
        sl<InvoicesRepo>(),
        sl<DiagnosisRepo>(),
      ));
  sl.registerFactory<LaboratoryCubit>(() => LaboratoryCubit(
        sl<LaboratoryRepo>(),
        sl<PatientsRepo>(),
        sl<InvoicesRepo>(),
        sl<DiagnosisRepo>(),
      ));
  sl.registerFactory<DiagnosisCubit>(() => DiagnosisCubit(sl<DiagnosisRepo>()));
  sl.registerFactory<InvoicesCubit>(() => InvoicesCubit(sl<InvoicesRepo>()));
  sl.registerFactory<ReportsCubit>(() => ReportsCubit(sl<InvoicesRepo>()));
}
