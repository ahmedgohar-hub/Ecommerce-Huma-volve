import '../../../../core/network/auth_session.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/signup_result_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/signup_req_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl([AuthRemoteDataSource? dataSource])
      : remoteDataSource = dataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<AuthTokenEntity> login({
    required String email,
    required String password,
  }) async {
    final loginData = await remoteDataSource.login(
      email: email,
      password: password,
    );

    AuthSession.setTokens(
      access: loginData.accessToken,
      refresh: loginData.refreshToken,
    );

    try {
      final profile = await remoteDataSource.getProfile();
      AuthSession.userId = profile.id;
      AuthSession.userName = profile.name;
      AuthSession.userEmail = profile.email;
      AuthSession.userAvatar = profile.avatar;
    } catch (_) {}

    return loginData;
  }

  @override
  Future<SignupResultEntity> signUp({
    required String name,
    required String email,
    required String password,
    String avatar = 'https://picsum.photos/800',
  }) async {
    final req = SignupReqModel(
      name: name,
      email: email,
      password: password,
      avatar: avatar,
    );
    return await remoteDataSource.signUp(req);
  }

  @override
  Future<UserEntity> getProfile() async {
    final profile = await remoteDataSource.getProfile();
    AuthSession.userId = profile.id;
    AuthSession.userName = profile.name;
    AuthSession.userEmail = profile.email;
    AuthSession.userAvatar = profile.avatar;
    return profile;
  }
}
