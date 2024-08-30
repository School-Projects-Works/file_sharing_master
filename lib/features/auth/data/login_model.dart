class LoginModel {
  String email;
  String password;

  LoginModel({required this.email, required this.password});

  LoginModel copyWith({
    String? email,
    String? password,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
