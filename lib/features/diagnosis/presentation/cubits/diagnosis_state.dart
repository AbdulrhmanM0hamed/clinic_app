part of 'diagnosis_cubit.dart';

sealed class DiagnosisState {}

class DiagnosisInitial extends DiagnosisState {}
class DiagnosisLoading extends DiagnosisState {}
class DiagnosisLoaded extends DiagnosisState {
  final List<DiagnosisCase> cases;
  DiagnosisLoaded(this.cases);
}
class DiagnosisError extends DiagnosisState {
  final String message;
  DiagnosisError(this.message);
}
class DiagnosisOperationLoading extends DiagnosisLoaded {
  DiagnosisOperationLoading(super.cases);
}
class DiagnosisOperationSuccess extends DiagnosisLoaded {
  DiagnosisOperationSuccess(super.cases);
}
class DiagnosisOperationError extends DiagnosisLoaded {
  final String errorMessage;
  DiagnosisOperationError(super.cases, this.errorMessage);
}
