import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/clinic_models.dart';
import '../../../../core/utils/result.dart';

abstract class LaboratoryRepo {
  Future<Result<List<LaboratoryOrder>, Failure>> fetchLaboratoryOrders();
  Future<Result<LaboratoryOrder, Failure>> addLaboratoryOrder(LaboratoryOrder order);
}

class LaboratoryRepoImpl implements LaboratoryRepo {
  final SupabaseClient _supabaseClient;
  
  LaboratoryRepoImpl(this._supabaseClient);

  final String _tableName = 'laboratory_orders';

  @override
  Future<Result<List<LaboratoryOrder>, Failure>> fetchLaboratoryOrders() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select('*, patients(*)')
          .order('created_at', ascending: false);
      
      final orders = (response as List).map((json) => _mapToLaboratoryOrder(json)).toList();
      return Success(orders);
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<LaboratoryOrder, Failure>> addLaboratoryOrder(LaboratoryOrder order) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .insert(_mapFromLaboratoryOrder(order))
          .select('*, patients(*)')
          .single();
          
      return Success(_mapToLaboratoryOrder(response));
    } on PostgrestException catch (e) {
      return FailureResult(SupabaseFailure.fromPostgrestException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  // Mappers
  LaboratoryOrder _mapToLaboratoryOrder(Map<String, dynamic> json) {
    return LaboratoryOrder(
      id: json['id'] as String,
      patient: _mapToPatientProfile(json['patients'] as Map<String, dynamic>),
      analysisType: json['analysis_type'] as String,
      notes: json['notes'] as String,
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      invoiceId: json['invoice_id'] as String,
    );
  }

  Map<String, dynamic> _mapFromLaboratoryOrder(LaboratoryOrder order) {
    return {
      if (order.id.isNotEmpty) 'id': order.id,
      'patient_id': order.patient.id,
      'analysis_type': order.analysisType,
      'notes': order.notes,
      'amount': order.amount,
      'invoice_id': order.invoiceId,
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
}
