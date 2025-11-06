// lib/features/auth/model/verify_code_response.dart
import 'dart:convert';

class VerifyCodeResponse {
  final bool success;
  final String message;
  final Data data;

  VerifyCodeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VerifyCodeResponse.fromRawJson(String str) =>
      VerifyCodeResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) =>
      VerifyCodeResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final User user;
  final Auth auth;

  Data({required this.user, required this.auth});

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: User.fromJson(json["user"]),
    auth: Auth.fromJson(json["auth"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "auth": auth.toJson(),
  };
}

class Auth {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  Auth({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory Auth.fromRawJson(String str) => Auth.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
    accessToken: json["access_token"],
    tokenType: json["token_type"],
    expiresIn: int.tryParse(json["expires_in"].toString()) ?? 0,
    refreshToken: json["refresh_token"],
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "token_type": tokenType,
    "expires_in": expiresIn,
    "refresh_token": refreshToken,
  };
}

class User {
  final int id;
  final String? name;
  final String email;
  final String phone;

  User({required this.id, this.name, required this.email, required this.phone});

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
  };
}
