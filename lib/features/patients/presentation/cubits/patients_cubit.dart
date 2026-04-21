import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/clinic_models.dart';
import '../../data/repo/patients_repo.dart';

part 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final PatientsRepo _repo;
  List<PatientProfile> _currentPatients = [];

  PatientsCubit(this._repo) : super(PatientsInitial());

  Future<void> fetchPatients() async {
    emit(PatientsLoading());
    final result = await _repo.fetchPatients();
    result.fold(
      (failure) => emit(PatientsError(failure.message)),
      (patients) {
        _currentPatients = patients;
        emit(PatientsLoaded(_currentPatients));
      },
    );
  }

  Future<void> addPatient(PatientProfile patient) async {
    emit(PatientOperationLoading(_currentPatients));
    final result = await _repo.addPatient(patient);
    result.fold(
      (failure) => emit(PatientOperationError(_currentPatients, failure.message)),
      (newPatient) {
        _currentPatients = [newPatient, ..._currentPatients];
        emit(PatientOperationSuccess(_currentPatients));
      },
    );
  }

  Future<void> updatePatient(PatientProfile patient) async {
    emit(PatientOperationLoading(_currentPatients));
    final result = await _repo.updatePatient(patient);
    result.fold(
      (failure) => emit(PatientOperationError(_currentPatients, failure.message)),
      (updatedPatient) {
        final index = _currentPatients.indexWhere((p) => p.id == updatedPatient.id);
        if (index != -1) {
          _currentPatients[index] = updatedPatient;
        }
        emit(PatientOperationSuccess(_currentPatients));
      },
    );
  }
}
