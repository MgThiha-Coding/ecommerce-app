class LoginRequest {
  final String emailOrPhoneOrUserName;
  final String password;
  final bool rememberMe;
  final String deviceName;

  LoginRequest({
    required this.emailOrPhoneOrUserName,
    required this.password,
    required this.rememberMe,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      "email_or_phone_or_username": emailOrPhoneOrUserName,
      "password": password,
      "remember_me": rememberMe,
      "device_name": deviceName,
    };
  }
}
