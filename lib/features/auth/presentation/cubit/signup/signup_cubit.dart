import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/usecases/signup_usecase.dart';
import 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpCubit({SignUpUseCase? useCase})
      : signUpUseCase = useCase ??
            SignUpUseCase(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
        super(const SignUpInitial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String avatar = 'https://picsum.photos/800',
  }) async {
    emit(const SignUpLoading());
    try {
      final result = await signUpUseCase(
        SignUpParams(
          name: name,
          email: email,
          password: password,
          avatar: avatar,
        ),
      );
      emit(SignUpSuccess(result));
    } catch (e) {
      final message = ApiClient.formatDioError(e);
      emit(SignUpFailure(message));
    }
  }
}
