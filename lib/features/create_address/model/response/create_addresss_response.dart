class CreateAddressResponse {
  final bool success;
  final String message;
  final AddressData? data;

  CreateAddressResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateAddressResponse.fromJson(Map<String, dynamic> json) {
    return CreateAddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AddressData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AddressData {
  final String name;
  final String firstName;
  final String lastName;
  final int contactId;
  final String addressLine1;
  final String addressLine2;
  final int townshipId;
  final int regionId;
  final String postalZipCode;
  final String country;
  final String phone;
  final bool isDefault;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;

  AddressData({
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.contactId,
    required this.addressLine1,
    required this.addressLine2,
    required this.townshipId,
    required this.regionId,
    required this.postalZipCode,
    required this.country,
    required this.phone,
    required this.isDefault,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      contactId: json['contact_id'] ?? 0,
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      townshipId: json['township_id'] ?? 0,
      regionId: json['region_id'] ?? 0,
      postalZipCode: json['postal_zip_code'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      isDefault: json['is_default'] ?? false,
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'contact_id': contactId,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'township_id': townshipId,
      'region_id': regionId,
      'postal_zip_code': postalZipCode,
      'country': country,
      'phone': phone,
      'is_default': isDefault,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'id': id,
    };
  }
}
