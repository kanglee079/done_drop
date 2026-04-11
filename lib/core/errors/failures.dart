/// Error handling types for DoneDrop
sealed class AppFailure {
  const AppFailure(this.message, {this.code});
  final String message;
  final String? code;

  factory AppFailure.unexpected([String? msg]) =>
      _UnexpectedFailure(msg ?? 'An unexpected error occurred.');
  factory AppFailure.network([String? msg]) =>
      _NetworkFailure(msg ?? 'Network error. Check your connection.');
  factory AppFailure.cancelled([String? msg]) =>
      _CancelledFailure(msg ?? 'Operation was cancelled.');
  factory AppFailure.notFound([String? msg]) =>
      _NotFoundFailure(msg ?? 'Resource not found.');
  factory AppFailure.conflict([String? msg]) =>
      _ConflictFailure(msg ?? 'Conflict occurred.');
  factory AppFailure.forbidden([String? msg]) =>
      _ForbiddenFailure(msg ?? 'Permission denied.');
  factory AppFailure.rateLimited([String? msg]) =>
      _RateLimitedFailure(msg ?? 'Too many requests. Please try again later.');
  factory AppFailure.invalidInput([String? msg]) =>
      _InvalidInputFailure(msg ?? 'Invalid input.');
  factory AppFailure.unauthorized([String? msg]) =>
      _UnauthorizedFailure(msg ?? 'Unauthorized access.');
}

class _UnexpectedFailure extends AppFailure {
  const _UnexpectedFailure(super.message) : super(code: null);
}
class _NetworkFailure extends AppFailure {
  const _NetworkFailure(super.message) : super(code: null);
}
class _CancelledFailure extends AppFailure {
  const _CancelledFailure(super.message) : super(code: null);
}
class _NotFoundFailure extends AppFailure {
  const _NotFoundFailure(super.message) : super(code: null);
}
class _ConflictFailure extends AppFailure {
  const _ConflictFailure(super.message) : super(code: null);
}
class _ForbiddenFailure extends AppFailure {
  const _ForbiddenFailure(super.message) : super(code: null);
}
class _RateLimitedFailure extends AppFailure {
  const _RateLimitedFailure(super.message) : super(code: null);
}
class _InvalidInputFailure extends AppFailure {
  const _InvalidInputFailure(super.message) : super(code: null);
}
class _UnauthorizedFailure extends AppFailure {
  const _UnauthorizedFailure(super.message) : super(code: null);
}

// ── Domain Failures ──────────────────────────────────────────────────────────
class NetworkFailure extends AppFailure {
  const NetworkFailure({String? code}) : super('Network error. Please check your connection.', code: code);
}

class ServerFailure extends AppFailure {
  const ServerFailure({String? code}) : super('Something went wrong. Please try again.', code: code);
}

class AuthFailure extends AppFailure {
  const AuthFailure({String? code}) : super('Authentication failed.', code: code);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure({String? code}) : super('Permission denied.', code: code);
}

class StorageFailure extends AppFailure {
  const StorageFailure({String? code}) : super('Failed to save data.', code: code);
}

class UploadFailure extends AppFailure {
  const UploadFailure({String? code}) : super('Failed to upload. Please try again.', code: code);
}

class InviteFailure extends AppFailure {
  const InviteFailure({String? code}) : super('Invalid or expired invite.', code: code);
}

class CircleFailure extends AppFailure {
  const CircleFailure({String? code}) : super('Circle operation failed.', code: code);
}

class SubscriptionFailure extends AppFailure {
  const SubscriptionFailure({String? code}) : super('Subscription error.', code: code);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({String? code}) : super('Invalid input.', code: code);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure({String? code}) : super('An unexpected error occurred.', code: code);
}
