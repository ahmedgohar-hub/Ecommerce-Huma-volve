import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/login_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

@Deprecated('Use AuthRepository or UseCases instead')
class LoginService {
  final AuthRepositoryImpl _authRepository;
  final AuthRemoteDataSource _remoteDataSource;

  LoginService([ApiClient? client])
      : _remoteDataSource = AuthRemoteDataSourceImpl(client),
        _authRepository = AuthRepositoryImpl(AuthRemoteDataSourceImpl(client));

  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    final token = await _authRepository.login(
      email: email,
      password: password,
    );
    return LoginModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
  }

  Future<UserProfileModel> getProfile() async {
    return await _remoteDataSource.getProfile();
  }
}
