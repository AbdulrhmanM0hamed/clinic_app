import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/clinic_models.dart';
import '../../data/repo/invoices_repo.dart';

part 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final InvoicesRepo _repo;
  List<ClinicInvoice> _currentInvoices = [];

  InvoicesCubit(this._repo) : super(InvoicesInitial());

  Future<void> fetchInvoices() async {
    emit(InvoicesLoading());
    final result = await _repo.fetchInvoices();
    result.fold(
      (failure) => emit(InvoicesError(failure.message)),
      (invoices) {
        _currentInvoices = invoices;
        emit(InvoicesLoaded(_currentInvoices));
      },
    );
  }

  Future<void> addInvoice(ClinicInvoice invoice) async {
    emit(InvoicesOperationLoading(_currentInvoices));
    final result = await _repo.addInvoice(invoice);
    result.fold(
      (failure) => emit(InvoicesOperationError(_currentInvoices, failure.message)),
      (newInvoice) {
        _currentInvoices = [newInvoice, ..._currentInvoices];
        emit(InvoicesOperationSuccess(_currentInvoices));
      },
    );
  }
}
