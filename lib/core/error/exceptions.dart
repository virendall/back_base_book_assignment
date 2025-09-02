abstract class AppException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  final int? statusCode;
  final Uri? uri;

  const ServerException({
    String message = 'Server error',
    this.statusCode,
    this.uri,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class CacheException extends AppException {
  const CacheException({
    String message = 'Cache error',
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}
