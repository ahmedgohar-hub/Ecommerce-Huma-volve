import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/signup_req_model.dart';
import '../models/signup_res_model.dart';

class SignupService {
  final ApiClient apiClient;

  SignupService([ApiClient? client]) : apiClient = client ?? ApiClient();

  Future<SignupResModel> signUp(SignupReqModel signupReqModel) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.signup,
      data: signupReqModel.toJson(),
    );

    return SignupResModel.fromJson(response.data as Map<String, dynamic>);
  }
}
