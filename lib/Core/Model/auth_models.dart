/// Simple request/response models for auth API.
class SignupRequest {
  SignupRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
  });

  final String email;
  final String username;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'password': password,
        'confirm_password': confirmPassword,
      };
}
