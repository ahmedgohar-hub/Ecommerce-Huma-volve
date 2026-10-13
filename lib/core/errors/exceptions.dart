class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server Exception']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network Exception']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Auth Exception']);

  @override
  String toString() => message;
}
