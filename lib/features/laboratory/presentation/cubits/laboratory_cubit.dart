import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/clinic_models.dart';
import '../../data/repo/laboratory_repo.dart';
import '../../../../features/patients/data/repo/patients_repo.dart';
import '../../../../features/invoices/data/repo/invoices_repo.dart';
import '../../../../features/diagnosis/data/repo/diagnosis_repo.dart';

part 'laboratory_state.dart';

class LaboratoryCubit extends Cubit<LaboratoryState> {
  final LaboratoryRepo _repo;
  final PatientsRepo _patientsRepo;
  final InvoicesRepo _invoicesRepo;
  final DiagnosisRepo _diagnosisRepo;
  List<LaboratoryOrder> _currentOrders = [];

  LaboratoryCubit(
    this._repo,
    this._patientsRepo,
    this._invoicesRepo,
    this._diagnosisRepo,
  ) : super(LaboratoryInitial());

  Future<void> fetchOrders() async {
    emit(LaboratoryLoading());
    final result = await _repo.fetchLaboratoryOrders();
    result.fold((failure) => emit(LaboratoryError(failure.message)), (orders) {
      _currentOrders = orders;
      emit(LaboratoryLoaded(_currentOrders));
    });
  }

  Future<void> addOrder(
    LaboratoryOrder order,
    PatientProfile patient,
    ClinicInvoice invoice,
  ) async {
    emit(LaboratoryOperationLoading(_currentOrders));

    // 1. Add/Update Patient & Get the real ID (UUID)
    final patientResult = await _patientsRepo.addPatient(patient);
    String realPatientId = '';

    if (patientResult.isFailure) {
      final errorMessage = patientResult.fold(
        (failure) => failure.message,
        (_) => '',
      );
      emit(
        LaboratoryOperationError(
          _currentOrders,
          'فشل حفظ بيانات المريض: $errorMessage',
        ),
      );
      return;
    } else {
      realPatientId = patientResult.fold((_) => '', (p) => p.id);
    }

    // 2. Add Invoice
    final updatedInvoice = invoice.copyWith(
      id: '',
      nationalId: patient.nationalId,
      nationality: patient.nationality,
      birthDate: patient.birthDate,
    );
    final invoiceResult = await _invoicesRepo.addInvoice(updatedInvoice);
    if (invoiceResult.isFailure) {
      final errorMessage = invoiceResult.fold(
        (failure) => failure.message,
        (_) => '',
      );
      emit(
        LaboratoryOperationError(
          _currentOrders,
          'فشل إنشاء الفاتورة: $errorMessage',
        ),
      );
      return;
    }
    final savedInvoice = invoiceResult.fold(
      (_) => updatedInvoice,
      (inv) => inv,
    );

    // 3. Add Diagnosis Case (for the doctor)
    final diagnosisCase = DiagnosisCase(
      id: '',
      invoiceId: savedInvoice.id,
      patientName: patient.fullName,
      nationality: patient.nationality,
      nationalId: patient.nationalId,
      phoneNumber: patient.phoneNumber,
      address: patient.address,
      source: CaseSource.laboratory,
      serviceLabel: invoice.serviceLabel,
      notes: order.notes,
      amount: order.amount,
      createdAt: order.createdAt,
    );
    await _diagnosisRepo.addDiagnosisCase(diagnosisCase);

    // 4. Add Record using the real patient ID
    final updatedOrder = order.copyWith(
      id: '',
      patient: patient.copyWith(id: realPatientId),
      invoiceId: savedInvoice.id,
    );

    final result = await _repo.addLaboratoryOrder(updatedOrder);
    result.fold(
      (failure) =>
          emit(LaboratoryOperationError(_currentOrders, failure.message)),
      (newOrder) {
        _currentOrders = [newOrder, ..._currentOrders];
        emit(LaboratoryOperationSuccess(_currentOrders));
      },
    );
  }
}
