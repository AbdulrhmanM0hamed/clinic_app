import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/clinic_models.dart';
import '../../../../core/utils/result.dart';

abstract class PatientsRepo {
  Future<Result<List<PatientProfile>, Failure>> fetchPatients();
  Future<Result<PatientProfile, Failure>> addPatient(PatientProfile patient);
  Future<Result<PatientProfile, Failure>> updatePatient(PatientProfile patient);
  Future<Result<void, Failure>> deletePatient(String id);
}

class PatientsRepoImpl implements PatientsRepo {
  final SupabaseClient _supabaseClient;
  
  PatientsRepoImpl(this._supabaseClient);

  final String _tableName = 'patients';

  @override
  Future<Result<List<PatientProfile>, Failure>> fetchPatients() async {
    try {
      final response = await _supabaseClient.from(_tableName).select().order('created_at', ascending: false);
      
      final patients = (response as List).map((json) => _mapToPatientProfile(json)).toList();
      return Success(patients);
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PatientProfile, Failure>> addPatient(PatientProfile patient) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(_mapFromPatientProfile(patient))
          .select()
          .single();
          
      return Success(_mapToPatientProfile(response));
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PatientProfile, Failure>> updatePatient(PatientProfile patient) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update(_mapFromPatientProfile(patient))
          .eq('id', patient.id)
          .select()
          .single();
          
      return Success(_mapToPatientProfile(response));
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deletePatient(String id) async {
    try {
      await _supabaseClient.from(_tableName).delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  // Mappers
  PatientProfile _mapToPatientProfile(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      nationality: json['nationality'] as String,
      nationalId: json['national_id'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      workplace: json['workplace'] as String?,
    );
  }

  Map<String, dynamic> _mapFromPatientProfile(PatientProfile profile) {
    return {
      if (profile.id.isNotEmpty) 'id': profile.id, // Only include if it has an ID, otherwise let Supabase generate UUID
      'full_name': profile.fullName,
      'nationality': profile.nationality,
      'national_id': profile.nationalId,
      'birth_date': "${profile.birthDate.year}-${profile.birthDate.month.toString().padLeft(2, '0')}-${profile.birthDate.day.toString().padLeft(2, '0')}", // YYYY-MM-DD for PG Date
      'phone_number': profile.phoneNumber,
      'address': profile.address,
      'workplace': profile.workplace,
    };
  }
}
