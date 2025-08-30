class RemoveCartItemResponse {
  final bool success;
  final String message;
  final RemoveCartItemData data;

  RemoveCartItemResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RemoveCartItemResponse.fromJson(Map<String, dynamic> json) {
    return RemoveCartItemResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: RemoveCartItemData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class RemoveCartItemData {
  final double remainingCartTotal;
  final int remainingItemsCount;

  RemoveCartItemData({
    required this.remainingCartTotal,
    required this.remainingItemsCount,
  });

  factory RemoveCartItemData.fromJson(Map<String, dynamic> json) {
    return RemoveCartItemData(
      remainingCartTotal: double.tryParse(json['remaining_cart_total']?.toString() ?? '0') ?? 0,
      remainingItemsCount: json['remaining_items_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'remaining_cart_total': remainingCartTotal.toStringAsFixed(2),
        'remaining_items_count': remainingItemsCount,
      };
}
