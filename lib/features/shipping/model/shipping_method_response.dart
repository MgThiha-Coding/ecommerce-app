class ShippingMethodResponse {
  final bool success;
  final String message;
  final List<ShippingMethod> data;

  ShippingMethodResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ShippingMethodResponse.fromJson(Map<String, dynamic> json) {
    return ShippingMethodResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ShippingMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ShippingMethod {
  final int id;
  final String name;
  final int deliveryChannelId;
  final String deliveryCalType;
  final String amount;
  final String? formulaDetails;
  final String descriptions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deliveryChannelName;
  final String deliveryChannelPhone;

  ShippingMethod({
    required this.id,
    required this.name,
    required this.deliveryChannelId,
    required this.deliveryCalType,
    required this.amount,
    this.formulaDetails,
    required this.descriptions,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryChannelName,
    required this.deliveryChannelPhone,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      deliveryChannelId: json['delivery_channel_id'] as int,
      deliveryCalType: json['delivery_cal_type'] as String,
      amount: json['amount'] as String,
      formulaDetails: json['formula_details'] as String?,
      descriptions: json['descriptions'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deliveryChannelName: json['delivery_channel_name'] as String,
      deliveryChannelPhone: json['delivery_channel_phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'delivery_channel_id': deliveryChannelId,
      'delivery_cal_type': deliveryCalType,
      'amount': amount,
      'formula_details': formulaDetails,
      'descriptions': descriptions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_channel_name': deliveryChannelName,
      'delivery_channel_phone': deliveryChannelPhone,
    };
  }
}
