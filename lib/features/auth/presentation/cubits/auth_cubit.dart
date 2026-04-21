import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    // Prevent empty queries safely
    if (username.isEmpty || password.isEmpty) return;

    emit(AuthLoading());

    // Fix Username appending rule
    String extractedEmail = username.trim();
    if (!extractedEmail.contains('@')) {
      extractedEmail = '$extractedEmail@clinic.com';
    }

    final result = await _authRepo.signIn(extractedEmail, password);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user.id)),
    );
  }
}
