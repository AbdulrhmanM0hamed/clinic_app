import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/clinic_models.dart';
import '../../data/repo/diagnosis_repo.dart';

part 'diagnosis_state.dart';

class DiagnosisCubit extends Cubit<DiagnosisState> {
  final DiagnosisRepo _repo;
  List<DiagnosisCase> _currentCases = [];

  DiagnosisCubit(this._repo) : super(DiagnosisInitial());

  Future<void> fetchCases() async {
    emit(DiagnosisLoading());
    final result = await _repo.fetchDiagnosisCases();
    result.fold(
      (failure) => emit(DiagnosisError(failure.message)),
      (cases) {
        _currentCases = cases;
        emit(DiagnosisLoaded(_currentCases));
      },
    );
  }

  Future<void> addCase(DiagnosisCase caseItem) async {
    emit(DiagnosisOperationLoading(_currentCases));
    final result = await _repo.addDiagnosisCase(caseItem);
    result.fold(
      (failure) => emit(DiagnosisOperationError(_currentCases, failure.message)),
      (newCase) {
        _currentCases = [newCase, ..._currentCases];
        emit(DiagnosisOperationSuccess(_currentCases));
      },
    );
  }
}
