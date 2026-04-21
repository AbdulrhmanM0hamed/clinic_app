part of 'laboratory_cubit.dart';

sealed class LaboratoryState {}

class LaboratoryInitial extends LaboratoryState {}
class LaboratoryLoading extends LaboratoryState {}
class LaboratoryLoaded extends LaboratoryState {
  final List<LaboratoryOrder> orders;
  LaboratoryLoaded(this.orders);
}
class LaboratoryError extends LaboratoryState {
  final String message;
  LaboratoryError(this.message);
}
class LaboratoryOperationLoading extends LaboratoryLoaded {
  LaboratoryOperationLoading(super.orders);
}
class LaboratoryOperationSuccess extends LaboratoryLoaded {
  LaboratoryOperationSuccess(super.orders);
}
class LaboratoryOperationError extends LaboratoryLoaded {
  final String message;
  LaboratoryOperationError(super.orders, this.message);
}
