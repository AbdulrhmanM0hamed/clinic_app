import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/clinic_models.dart';
import '../../../../core/utils/result.dart';

abstract class DiagnosisRepo {
  Future<Result<List<DiagnosisCase>, Failure>> fetchDiagnosisCases();
  Future<Result<DiagnosisCase, Failure>> addDiagnosisCase(DiagnosisCase caseItem);
}

class DiagnosisRepoImpl implements DiagnosisRepo {
  final SupabaseClient _supabaseClient;
  
  DiagnosisRepoImpl(this._supabaseClient);

  final String _tableName = 'diagnosis_cases';

  @override
  Future<Result<List<DiagnosisCase>, Failure>> fetchDiagnosisCases() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      final cases = (response as List).map((json) => _mapToDiagnosisCase(json)).toList();
      return Success(cases);
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<DiagnosisCase, Failure>> addDiagnosisCase(DiagnosisCase caseItem) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(_mapFromDiagnosisCase(caseItem))
          .select()
          .single();
          
      return Success(_mapToDiagnosisCase(response));
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  // Mappers
  DiagnosisCase _mapToDiagnosisCase(Map<String, dynamic> json) {
    return DiagnosisCase(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      patientName: json['patient_name'] as String,
      nationality: json['nationality'] as String,
      nationalId: json['national_id'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      source: _parseCaseSource(json['source'] as String),
      serviceLabel: json['service_label'] as String,
      notes: json['notes'] as String,
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> _mapFromDiagnosisCase(DiagnosisCase caseItem) {
    return {
      if (caseItem.id.isNotEmpty) 'id': caseItem.id,
      'invoice_id': caseItem.invoiceId,
      'patient_name': caseItem.patientName,
      'nationality': caseItem.nationality,
      'national_id': caseItem.nationalId,
      'phone_number': caseItem.phoneNumber,
      'address': caseItem.address,
      'source': caseItem.source.name,
      'service_label': caseItem.serviceLabel,
      'notes': caseItem.notes,
      'amount': caseItem.amount,
    };
  }

  CaseSource _parseCaseSource(String sourceStr) {
    return CaseSource.values.firstWhere(
      (e) => e.name == sourceStr,
      orElse: () => CaseSource.reception, // default
    );
  }
}
