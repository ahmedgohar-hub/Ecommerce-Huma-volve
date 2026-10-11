import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import 'auth_session.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(seconds: ApiConstants.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Auth token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AuthSession.accessToken != null &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] =
                'Bearer ${AuthSession.accessToken}';
          }
          return handler.next(options);
        },
      ),
    );

    // Add Logger interceptor in debug mode
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: !const bool.fromEnvironment('dart.vm.product'),
      ),
    );
  }

  static String formatDioError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'];
          if (message is List) {
            return message.join('\n');
          } else if (message is String) {
            return message;
          }
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Invalid email or password.';
          } else if (statusCode == 400) {
            return 'Invalid request details. Please check your inputs.';
          }
          return 'Request failed with status: $statusCode';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the server. Please check your internet.';
        default:
          return error.message ?? 'An unexpected error occurred.';
      }
    }
    return error.toString();
  }
}
