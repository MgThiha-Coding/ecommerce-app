class LoginResponse {
  final bool success;
  final String message;
  final Data data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }

  void operator [](String other) {}
}

class Data {
  final User user;
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  Data({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      expiresIn: int.tryParse(json['expires_in'].toString()) ?? 0,
      refreshToken: json['refresh_token'] ?? '',
    );
  }

  void operator [](String other) {}
}

class User {
  final int id;
  final dynamic name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
