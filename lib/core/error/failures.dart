import 'package:equatable/equatable.dart';

/// Failures returned on the Left side of Either from repositories / use cases.
/// Presentation layers should show [message] to the user.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// HTTP / API business-status errors (4xx/5xx or `status != 1`).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Timeouts, no connectivity, cancelled requests.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// SharedPreferences / local cache read-write errors.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Client-side validation (empty fields, bad input).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
