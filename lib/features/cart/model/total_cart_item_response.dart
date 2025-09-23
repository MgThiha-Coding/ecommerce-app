class TotalCartItemResponse {
  final bool success;
  final String message;
  final int data;

  TotalCartItemResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TotalCartItemResponse.fromJson(Map<String, dynamic> json) {
    return TotalCartItemResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] is int)
          ? json['data'] as int
          : int.tryParse(json['data'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data,
      };
}
