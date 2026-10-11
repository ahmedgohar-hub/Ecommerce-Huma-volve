class SignupReqModel {
  final String name;
  final String email;
  final String password;
  final String avatar;

  SignupReqModel({
    required this.name,
    required this.email,
    required this.password,
    this.avatar = 'https://picsum.photos/800',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
    };
  }
}
