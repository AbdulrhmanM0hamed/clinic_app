part of 'invoices_cubit.dart';

sealed class InvoicesState {}

class InvoicesInitial extends InvoicesState {}
class InvoicesLoading extends InvoicesState {}
class InvoicesLoaded extends InvoicesState {
  final List<ClinicInvoice> invoices;
  InvoicesLoaded(this.invoices);
}
class InvoicesError extends InvoicesState {
  final String message;
  InvoicesError(this.message);
}
class InvoicesOperationLoading extends InvoicesLoaded {
  InvoicesOperationLoading(super.invoices);
}
class InvoicesOperationSuccess extends InvoicesLoaded {
  InvoicesOperationSuccess(super.invoices);
}
class InvoicesOperationError extends InvoicesLoaded {
  final String errorMessage;
  InvoicesOperationError(super.invoices, this.errorMessage);
}
