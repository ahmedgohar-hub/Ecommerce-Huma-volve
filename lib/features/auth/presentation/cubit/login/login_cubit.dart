import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit({LoginUseCase? useCase})
      : loginUseCase = useCase ??
            LoginUseCase(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
        super(const LoginInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const LoginLoading());
    try {
      final tokens = await loginUseCase(
        LoginParams(email: email, password: password),
      );
      emit(LoginSuccess(tokens));
    } catch (e) {
      final message = ApiClient.formatDioError(e);
      emit(LoginFailure(message));
    }
  }
}
