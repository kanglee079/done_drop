/// DoneDrop Result type — Either success or failure without exceptions
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(dynamic failure) = Failure<T>;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final dynamic failure;
}

extension ResultExt<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(dynamic failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Failure<T>(:final failure) => onFailure(failure),
      };

  Result<R> map<R>(R Function(T data) mapper) => switch (this) {
        Success<T>(:final data) => Success(mapper(data)),
        Failure<T>(:final failure) => Failure(failure),
      };
}
