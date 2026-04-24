/// Error handling types for DoneDrop
sealed class AppFailure {
  const AppFailure(this.message, {this.code});
  final String message;
  final String? code;

  factory AppFailure.unexpected([String? msg, String? code]) =>
      _UnexpectedFailure(msg ?? 'An unexpected error occurred.', code: code);
  factory AppFailure.network([String? msg, String? code]) => _NetworkFailure(
    msg ?? 'Network error. Check your connection.',
    code: code,
  );
  factory AppFailure.cancelled([String? msg, String? code]) =>
      _CancelledFailure(msg ?? 'Operation was cancelled.', code: code);
  factory AppFailure.notFound([String? msg, String? code]) =>
      _NotFoundFailure(msg ?? 'Resource not found.', code: code);
  factory AppFailure.conflict([String? msg, String? code]) =>
      _ConflictFailure(msg ?? 'Conflict occurred.', code: code);
  factory AppFailure.forbidden([String? msg, String? code]) =>
      _ForbiddenFailure(msg ?? 'Permission denied.', code: code);
  factory AppFailure.rateLimited([String? msg, String? code]) =>
      _RateLimitedFailure(
        msg ?? 'Too many requests. Please try again later.',
        code: code,
      );
  factory AppFailure.invalidInput([String? msg, String? code]) =>
      _InvalidInputFailure(msg ?? 'Invalid input.', code: code);
  factory AppFailure.unauthorized([String? msg, String? code]) =>
      _UnauthorizedFailure(msg ?? 'Unauthorized access.', code: code);
}

class _UnexpectedFailure extends AppFailure {
  const _UnexpectedFailure(super.message, {super.code});
}

class _NetworkFailure extends AppFailure {
  const _NetworkFailure(super.message, {super.code});
}

class _CancelledFailure extends AppFailure {
  const _CancelledFailure(super.message, {super.code});
}

class _NotFoundFailure extends AppFailure {
  const _NotFoundFailure(super.message, {super.code});
}

class _ConflictFailure extends AppFailure {
  const _ConflictFailure(super.message, {super.code});
}

class _ForbiddenFailure extends AppFailure {
  const _ForbiddenFailure(super.message, {super.code});
}

class _RateLimitedFailure extends AppFailure {
  const _RateLimitedFailure(super.message, {super.code});
}

class _InvalidInputFailure extends AppFailure {
  const _InvalidInputFailure(super.message, {super.code});
}

class _UnauthorizedFailure extends AppFailure {
  const _UnauthorizedFailure(super.message, {super.code});
}

// ── Domain Failures ──────────────────────────────────────────────────────────
class NetworkFailure extends AppFailure {
  const NetworkFailure({String? code})
    : super('Network error. Please check your connection.', code: code);
}

class ServerFailure extends AppFailure {
  const ServerFailure({String? code})
    : super('Something went wrong. Please try again.', code: code);
}

class AuthFailure extends AppFailure {
  const AuthFailure({String? code})
    : super('Authentication failed.', code: code);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure({String? code})
    : super('Permission denied.', code: code);
}

class StorageFailure extends AppFailure {
  const StorageFailure({String? code})
    : super('Failed to save data.', code: code);
}

class UploadFailure extends AppFailure {
  const UploadFailure({String? code})
    : super('Failed to upload. Please try again.', code: code);
}

class InviteFailure extends AppFailure {
  const InviteFailure({String? code})
    : super('Invalid or expired invite.', code: code);
}

class CircleFailure extends AppFailure {
  const CircleFailure({String? code})
    : super('Circle operation failed.', code: code);
}

class SubscriptionFailure extends AppFailure {
  const SubscriptionFailure({String? code})
    : super('Subscription error.', code: code);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({String? code}) : super('Invalid input.', code: code);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure({String? code})
    : super('An unexpected error occurred.', code: code);
}
