sealed class Result<T, F> {
  const Result();
}

final class Success<T, F> extends Result<T, F> {
  final T data;

  const Success(this.data);
}

final class FailureResult<T, F> extends Result<T, F> {
  final F error;

  const FailureResult(this.error);
}
