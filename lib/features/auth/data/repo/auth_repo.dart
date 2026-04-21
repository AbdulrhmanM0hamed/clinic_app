import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';

abstract class AuthRepo {
  Future<Result<User, Failure>> signIn(String email, String password);
}

class AuthRepoImpl implements AuthRepo {
  final SupabaseClient _supabaseClient;
  
  AuthRepoImpl(this._supabaseClient);

  @override
  Future<Result<User, Failure>> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email, 
        password: password
      );
      
      if (response.user != null) {
        return Success(response.user!);
      } else {
        return FailureResult(ServerFailure("فشل استرجاع بيانات المستخدم"));
      }
    } on AuthException catch (e) {
      return FailureResult(SupabaseFailure.fromAuthException(e));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
