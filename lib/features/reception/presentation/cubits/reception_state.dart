part of 'reception_cubit.dart';

sealed class ReceptionState {}

class ReceptionInitial extends ReceptionState {}
class ReceptionLoading extends ReceptionState {}
class ReceptionLoaded extends ReceptionState {
  final List<ReceptionRecord> records;
  ReceptionLoaded(this.records);
}
class ReceptionError extends ReceptionState {
  final String message;
  ReceptionError(this.message);
}
class ReceptionOperationLoading extends ReceptionLoaded {
  ReceptionOperationLoading(super.records);
}
class ReceptionOperationSuccess extends ReceptionLoaded {
  ReceptionOperationSuccess(super.records);
}
class ReceptionOperationError extends ReceptionLoaded {
  final String message;
  ReceptionOperationError(super.records, this.message);
}
