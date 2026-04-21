import 'package:clinic_app/core/errors/failures.dart';

sealed class Result<S, F extends Failure> {
  const Result();

  /// Handle both cases
  T fold<T>(T Function(F failure) onFailure, T Function(S data) onSuccess) {
    if (this is Success<S, F>) {
      return onSuccess((this as Success<S, F>).data);
    } else {
      return onFailure((this as FailureResult<S, F>).failure);
    }
  }

  /// Check if the result is success
  bool get isSuccess => this is Success<S, F>;

  /// Check if the result is failure
  bool get isFailure => this is FailureResult<S, F>;
}

class Success<S, F extends Failure> extends Result<S, F> {
  const Success(this.data);
  final S data;
}

class FailureResult<S, F extends Failure> extends Result<S, F> {
  const FailureResult(this.failure);
  final F failure;
}
