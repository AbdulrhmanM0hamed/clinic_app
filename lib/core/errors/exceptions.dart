class ServerException implements Exception {}

class OfflineException implements Exception {}

class SupabaseServerException implements Exception {
  final String message;
  final String? code;
  final String? hint;

  SupabaseServerException(this.message, {this.code, this.hint});
}
