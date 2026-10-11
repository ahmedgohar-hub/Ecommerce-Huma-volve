class AuthSession {
  static String? accessToken;
  static String? refreshToken;
  static int? userId;
  static String? userName;
  static String? userEmail;
  static String? userAvatar;

  static bool get isAuthenticated =>
      accessToken != null && accessToken!.isNotEmpty;

  static void setTokens({required String access, required String refresh}) {
    accessToken = access;
    refreshToken = refresh;
  }

  static void clear() {
    accessToken = null;
    refreshToken = null;
    userId = null;
    userName = null;
    userEmail = null;
    userAvatar = null;
  }
}
