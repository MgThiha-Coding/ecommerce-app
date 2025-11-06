import 'dart:convert';

class RegisterResponse {
  final bool success;
  final String message;
  final Data data;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  RegisterResponse copyWith({bool? success, String? message, Data? data}) =>
      RegisterResponse(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
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

  Data copyWith({User? user, Auth? auth}) =>
      Data(user: user ?? this.user, auth: auth ?? this.auth);

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

  Auth copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? refreshToken,
  }) => Auth(
    accessToken: accessToken ?? this.accessToken,
    tokenType: tokenType ?? this.tokenType,
    expiresIn: expiresIn ?? this.expiresIn,
    refreshToken: refreshToken ?? this.refreshToken,
  );

  factory Auth.fromRawJson(String str) => Auth.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
    accessToken: json["access_token"],
    tokenType: json["token_type"],
    expiresIn: json["expires_in"],
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
  final dynamic name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  User copyWith({int? id, dynamic name, String? email, String? phone}) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
  );

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
