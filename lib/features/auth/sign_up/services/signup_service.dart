import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/signup_req_model.dart';
import '../../data/models/signup_res_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

@Deprecated('Use AuthRepository or UseCases instead')
class SignupService {
  final AuthRepositoryImpl _authRepository;

  SignupService([ApiClient? client])
      : _authRepository = AuthRepositoryImpl(AuthRemoteDataSourceImpl(client));

  Future<SignupResModel> signUp(SignupReqModel signupReqModel) async {
    final result = await _authRepository.signUp(
      name: signupReqModel.name,
      email: signupReqModel.email,
      password: signupReqModel.password,
      avatar: signupReqModel.avatar,
    );

    return SignupResModel(
      id: result.id,
      email: result.email,
      name: result.name,
      role: result.role,
      avatar: result.avatar,
      creationAt: result.creationAt,
      updatedAt: result.updatedAt,
    );
  }
}
