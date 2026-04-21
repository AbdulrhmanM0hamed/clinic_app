part of 'patients_cubit.dart';

sealed class PatientsState {}

class PatientsInitial extends PatientsState {}
class PatientsLoading extends PatientsState {}
class PatientsLoaded extends PatientsState {
  final List<PatientProfile> patients;
  PatientsLoaded(this.patients);
}
class PatientsError extends PatientsState {
  final String message;
  PatientsError(this.message);
}
class PatientOperationLoading extends PatientsLoaded {
  PatientOperationLoading(super.patients);
}
class PatientOperationSuccess extends PatientsLoaded {
  PatientOperationSuccess(super.patients);
}
class PatientOperationError extends PatientsLoaded {
  final String errorMessage;
  PatientOperationError(super.patients, this.errorMessage);
}
