import '../../../domain/entities/auth_token_entity.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final AuthTokenEntity tokens;
  const LoginSuccess(this.tokens);
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
}
