class PaymentMethodResponse {
  final bool success;
  final String message;
  final List<PaymentMethod> data;

  PaymentMethodResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
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

class PaymentMethod {
  final int id;
  final String name;
  final String? logo;
  final int? paymentAccountId;
  final int? currenyId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? logoUrl;
  final PaymentAccount? paymentAccount;

  PaymentMethod({
    required this.id,
    required this.name,
    this.logo,
    this.paymentAccountId,
    this.currenyId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.paymentAccount,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      paymentAccountId: json['payment_account_id'] as int?,
      currenyId: json['curreny_id'] as int?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      logoUrl: json['logo_url'] as String?,
      paymentAccount: json['payment_account'] != null
          ? PaymentAccount.fromJson(json['payment_account'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'payment_account_id': paymentAccountId,
      'curreny_id': currenyId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'logo_url': logoUrl,
      'payment_account': paymentAccount?.toJson(),
    };
  }
}

class PaymentAccount {
  final int id;
  final String name;
  final String? accountType;
  final String? accountNumber;
  final String? description;
  final String openingAmount;
  final String currentBalance;
  final int currencyId;
  final String? qrimage;
  final String? qrimageUrl;

  PaymentAccount({
    required this.id,
    required this.name,
    this.accountType,
    this.accountNumber,
    this.description,
    required this.openingAmount,
    required this.currentBalance,
    required this.currencyId,
    this.qrimage,
    this.qrimageUrl,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      id: json['id'] as int,
      name: json['name'] as String,
      accountType: json['account_type'] as String?,
      accountNumber: json['account_number'] as String?,
      description: json['description'] as String?,
      openingAmount: json['opening_amount'] as String,
      currentBalance: json['current_balance'] as String,
      currencyId: json['currency_id'] as int,
      qrimage: json['qrimage'] as String?,
      qrimageUrl: json['qrimage_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'account_type': accountType,
      'account_number': accountNumber,
      'description': description,
      'opening_amount': openingAmount,
      'current_balance': currentBalance,
      'currency_id': currencyId,
      'qrimage': qrimage,
      'qrimage_url': qrimageUrl,
    };
  }
}
