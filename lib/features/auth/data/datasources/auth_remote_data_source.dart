import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_model.dart';
import '../models/signup_req_model.dart';
import '../models/signup_res_model.dart';
import '../models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginModel> login({
    required String email,
    required String password,
  });

  Future<SignupResModel> signUp(SignupReqModel signupReqModel);

  Future<UserProfileModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl([ApiClient? client])
      : apiClient = client ?? ApiClient();

  @override
  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return LoginModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(ApiClient.formatDioError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SignupResModel> signUp(SignupReqModel signupReqModel) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.signup,
        data: signupReqModel.toJson(),
      );
      return SignupResModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(ApiClient.formatDioError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.profile);
      return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(ApiClient.formatDioError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
