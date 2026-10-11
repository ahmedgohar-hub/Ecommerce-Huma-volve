import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_session.dart';
import '../../models/user_profile_model.dart';
import '../models/login_model.dart';

class LoginService {
  final ApiClient apiClient;

  LoginService([ApiClient? client]) : apiClient = client ?? ApiClient();

  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final loginData = LoginModel.fromJson(response.data as Map<String, dynamic>);

    // Store active tokens in session
    AuthSession.setTokens(
      access: loginData.accessToken,
      refresh: loginData.refreshToken,
    );

    // Optionally fetch user profile to populate session
    try {
      final profile = await getProfile();
      AuthSession.userId = profile.id;
      AuthSession.userName = profile.name;
      AuthSession.userEmail = profile.email;
      AuthSession.userAvatar = profile.avatar;
    } catch (_) {
      // Continue even if profile fetching fails
    }

    return loginData;
  }

  Future<UserProfileModel> getProfile() async {
    final response = await apiClient.dio.get(
      ApiEndpoints.profile,
    );
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
