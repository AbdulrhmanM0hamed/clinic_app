import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/clinic_models.dart';
import '../../../../core/utils/result.dart';

abstract class InvoicesRepo {
  Future<Result<List<ClinicInvoice>, Failure>> fetchInvoices();
  Future<Result<ClinicInvoice, Failure>> addInvoice(ClinicInvoice invoice);
}

class InvoicesRepoImpl implements InvoicesRepo {
  final SupabaseClient _supabaseClient;
  
  InvoicesRepoImpl(this._supabaseClient);

  final String _tableName = 'clinic_invoices';

  @override
  Future<Result<List<ClinicInvoice>, Failure>> fetchInvoices() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      final records = (response as List).map((json) => _mapToClinicInvoice(json)).toList();
      return Success(records);
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ClinicInvoice, Failure>> addInvoice(ClinicInvoice invoice) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(_mapFromClinicInvoice(invoice))
          .select()
          .single();
          
      return Success(_mapToClinicInvoice(response));
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  ClinicInvoice _mapToClinicInvoice(Map<String, dynamic> json) {
    return ClinicInvoice(
      id: json['id'] as String,
      patientName: json['patient_name'] as String,
      phoneNumber: json['phone_number'] as String,
      nationalId: json['national_id'] as String,
      serviceLabel: json['service_label'] as String,
      source: _parseCaseSource(json['source'] as String),
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      notes: json['notes'] as String,
      nationality: json['nationality'] as String? ?? 'غير محدد',
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _mapFromClinicInvoice(ClinicInvoice invoice) {
    return {
      if (invoice.id.isNotEmpty) 'id': invoice.id,
      'patient_name': invoice.patientName,
      'phone_number': invoice.phoneNumber,
      'national_id': invoice.nationalId,
      'service_label': invoice.serviceLabel,
      'source': invoice.source.name,
      'amount': invoice.amount,
      'notes': invoice.notes,
      'nationality': invoice.nationality,
      'birth_date': invoice.birthDate.toIso8601String(),
    };
  }

  CaseSource _parseCaseSource(String sourceStr) {
    return CaseSource.values.firstWhere(
      (e) => e.name == sourceStr,
      orElse: () => CaseSource.reception, // default
    );
  }
}
