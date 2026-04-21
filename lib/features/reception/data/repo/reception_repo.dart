import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/clinic_models.dart';
import '../../../../core/utils/result.dart';

abstract class ReceptionRepo {
  Future<Result<List<ReceptionRecord>, Failure>> fetchReceptionRecords();
  Future<Result<ReceptionRecord, Failure>> addReceptionRecord(ReceptionRecord record);
}

class ReceptionRepoImpl implements ReceptionRepo {
  final SupabaseClient _supabaseClient;
  
  ReceptionRepoImpl(this._supabaseClient);

  final String _tableName = 'reception_records';

  @override
  Future<Result<List<ReceptionRecord>, Failure>> fetchReceptionRecords() async {
    try {
      // Joining patients table to retrieve the full patient profile automatically
      final response = await _supabaseClient
          .from(_tableName)
          .select('*, patients(*)')
          .order('created_at', ascending: false);
      
      final records = (response as List).map((json) => _mapToReceptionRecord(json)).toList();
      return Success(records);
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ReceptionRecord, Failure>> addReceptionRecord(ReceptionRecord record) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(_mapFromReceptionRecord(record))
          .select('*, patients(*)')
          .single();
          
      return Success(_mapToReceptionRecord(response));
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  // Mappers
  ReceptionRecord _mapToReceptionRecord(Map<String, dynamic> json) {
    return ReceptionRecord(
      id: json['id'] as String,
      patient: _mapToPatientProfile(json['patients'] as Map<String, dynamic>),
      visitType: _parseVisitType(json['visit_type'] as String),
      notes: json['notes'] as String,
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      invoiceId: json['invoice_id'] as String,
    );
  }

  Map<String, dynamic> _mapFromReceptionRecord(ReceptionRecord record) {
    return {
      if (record.id.isNotEmpty) 'id': record.id,
      'patient_id': record.patient.id, // Only send the foreign key
      'visit_type': record.visitType.name,
      'notes': record.notes,
      'amount': record.amount,
      'invoice_id': record.invoiceId,
    };
  }

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

  VisitType _parseVisitType(String typeStr) {
    return VisitType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => VisitType.consultation,
    );
  }
}
