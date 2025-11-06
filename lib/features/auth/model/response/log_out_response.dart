class LogOutResponse {
  final bool success;
  final String message;

  LogOutResponse({required this.success, required this.message});

  factory LogOutResponse.fromJson(Map<String, dynamic> json) {
    return LogOutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}
