import '../../../../features/diagnosis/data/repo/diagnosis_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/clinic_models.dart';
import '../../data/repo/reception_repo.dart';
import '../../../../features/patients/data/repo/patients_repo.dart';
import '../../../../features/invoices/data/repo/invoices_repo.dart';

part 'reception_state.dart';

class ReceptionCubit extends Cubit<ReceptionState> {
  final ReceptionRepo _repo;
  final PatientsRepo _patientsRepo;
  final InvoicesRepo _invoicesRepo;
  final DiagnosisRepo _diagnosisRepo;
  List<ReceptionRecord> _currentRecords = [];

  ReceptionCubit(
    this._repo,
    this._patientsRepo,
    this._invoicesRepo,
    this._diagnosisRepo,
  ) : super(ReceptionInitial());

  Future<void> fetchRecords() async {
    emit(ReceptionLoading());
    final result = await _repo.fetchReceptionRecords();
    result.fold((failure) => emit(ReceptionError(failure.message)), (records) {
      _currentRecords = records;
      emit(ReceptionLoaded(_currentRecords));
    });
  }

  Future<void> addRecord(
    ReceptionRecord record,
    PatientProfile patient,
    ClinicInvoice invoice,
  ) async {
    emit(ReceptionOperationLoading(_currentRecords));

    // 1. Add/Update Patient & Get the real ID (UUID)
    final patientResult = await _patientsRepo.addPatient(patient);
    String realPatientId = '';

    if (patientResult.isFailure) {
      final errorMessage = patientResult.fold(
        (failure) => failure.message,
        (_) => '',
      );
      emit(
        ReceptionOperationError(
          _currentRecords,
          'فشل حفظ بيانات المريض: $errorMessage',
        ),
      );
      return;
    } else {
      realPatientId = patientResult.fold((_) => '', (p) => p.id);
    }

    // 2. Prepare the updated Invoice & Record with the real UUID
    final updatedInvoice = invoice.copyWith(
      id: '',
      nationalId: patient.nationalId,
      nationality: patient.nationality,
      birthDate: patient.birthDate,
    ); // Let DB generate ID

    // We need to wait for invoice to be saved to get its generated ID for diagnosis case if needed
    final invoiceResult = await _invoicesRepo.addInvoice(updatedInvoice);
    if (invoiceResult.isFailure) {
      final errorMessage = invoiceResult.fold(
        (failure) => failure.message,
        (_) => '',
      );
      emit(
        ReceptionOperationError(
          _currentRecords,
          'فشل إنشاء الفاتورة: $errorMessage',
        ),
      );
      return;
    }
    final savedInvoice = invoiceResult.fold(
      (_) => updatedInvoice,
      (inv) => inv,
    );

    // 3. Add Diagnosis Case (So doctor sees it in his page)
    final diagnosisCase = DiagnosisCase(
      id: '',
      invoiceId: savedInvoice.id,
      patientName: patient.fullName,
      nationality: patient.nationality,
      nationalId: patient.nationalId,
      phoneNumber: patient.phoneNumber,
      address: patient.address,
      source: CaseSource.reception,
      serviceLabel: invoice.serviceLabel,
      notes: record.notes,
      amount: record.amount,
      createdAt: record.createdAt,
    );
    await _diagnosisRepo.addDiagnosisCase(diagnosisCase);

    // 4. Add Reception Record using the real patient ID
    final updatedRecord = record.copyWith(
      id: '', // Let DB generate ID
      patient: patient.copyWith(id: realPatientId),
      invoiceId: savedInvoice.id,
    );

    final result = await _repo.addReceptionRecord(updatedRecord);
    result.fold(
      (failure) =>
          emit(ReceptionOperationError(_currentRecords, failure.message)),
      (newRecord) {
        _currentRecords = [newRecord, ..._currentRecords];
        emit(ReceptionOperationSuccess(_currentRecords));
      },
    );
  }
}
