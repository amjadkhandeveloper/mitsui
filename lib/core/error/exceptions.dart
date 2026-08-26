// Thrown in the data layer; repositories convert these into Failure types.
// Do not catch these in UI — map them at the repository boundary.

/// Backend returned an error status or an unexpected payload.
class ServerException implements Exception {
  final String message;

  const ServerException(this.message);
}

/// Timeout, socket, or no-connectivity errors from Dio.
class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);
}

/// Local storage read/write failed.
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}

/// Request payload failed client or server validation.
class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);
}
