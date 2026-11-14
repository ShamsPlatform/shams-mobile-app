/// Base exceptions thrown only inside data sources and mapped into [Failure]s
/// by repositories.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException($message)';
}

/// Named [AppAuthException] to avoid clashing with Supabase's `AuthException`.
class AppAuthException implements Exception {
  final String message;
  const AppAuthException(this.message);

  @override
  String toString() => 'AppAuthException($message)';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException($message)';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException($message)';
}
