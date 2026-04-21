import 'package:supabase_flutter/supabase_flutter.dart';

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class OfflineFailure extends Failure {
  const OfflineFailure() : super('لا يوجد اتصال بالإنترنت، يرجى المحاولة لاحقاً');
}

class SupabaseFailure extends Failure {
  final String? code;
  final String? hint;

  const SupabaseFailure(super.message, {this.code, this.hint});

  factory SupabaseFailure.fromPostgrestException(PostgrestException exception) {
    return SupabaseFailure(
      _getReadableMessage(exception.code, exception.message),
      code: exception.code,
      hint: exception.hint,
    );
  }

  factory SupabaseFailure.fromAuthException(AuthException exception) {
    return SupabaseFailure(
      _getReadableMessage(exception.statusCode, exception.message),
      code: exception.statusCode,
    );
  }

  static String _getReadableMessage(dynamic code, String originalMessage) {
    switch (code) {
      case '23505': // unique_violation
        return 'هذا السجل موجود مسبقاً.';
      case '23503': // foreign_key_violation
        return 'يوجد خطأ في الربط ببيانات أخرى (مثل ارتباط مريض بسجل غير موجود).';
      case 401: // Unauthorized (Auth specific)
        return 'عذراً، يجب تسجيل الدخول للقيام بهذه العملية.';
      default:
        // By default return original message or a generic one
        return 'حدث خطأ في الخادم المستضيف: $originalMessage';
    }
  }
}
