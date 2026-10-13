import '../../../domain/entities/signup_result_entity.dart';

abstract class SignUpState {
  const SignUpState();
}

class SignUpInitial extends SignUpState {
  const SignUpInitial();
}

class SignUpLoading extends SignUpState {
  const SignUpLoading();
}

class SignUpSuccess extends SignUpState {
  final SignupResultEntity result;
  const SignUpSuccess(this.result);
}

class SignUpFailure extends SignUpState {
  final String message;
  const SignUpFailure(this.message);
}
