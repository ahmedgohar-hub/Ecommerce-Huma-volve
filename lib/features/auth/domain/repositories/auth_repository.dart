import '../entities/auth_token_entity.dart';
import '../entities/signup_result_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthTokenEntity> login({
    required String email,
    required String password,
  });

  Future<SignupResultEntity> signUp({
    required String name,
    required String email,
    required String password,
    String avatar = 'https://picsum.photos/800',
  });

  Future<UserEntity> getProfile();
}
