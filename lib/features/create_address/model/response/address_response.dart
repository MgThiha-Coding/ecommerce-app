// address_response.dart
class AddressResponse {
  final bool success;
  final String message;
  final List<AddressData> data;

  AddressResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((e) => AddressData.fromJson(e))
        .toList();
    return AddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: list,
    );
  }
}
class AddressData {
  final int id;
  final int contactId;
  final String name;
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String addressLine2;
  final int townshipId;
  final int regionId;
  final String postalZipCode;
  final String country;
  final String phone;
  final bool isDefault;
  final String regionEnName;
  final String townshipEnName;

  AddressData({
    required this.id,
    required this.contactId,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    required this.addressLine2,
    required this.townshipId,
    required this.regionId,
    required this.postalZipCode,
    required this.country,
    required this.phone,
    required this.isDefault,
    required this.regionEnName,
    required this.townshipEnName,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      id: json['id'],
      contactId: json['contact_id'],
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      townshipId: json['township_id'] ?? 0,
      regionId: json['region_id'] ?? 0,
      postalZipCode: json['postal_zip_code'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      isDefault: json['is_default'] == 1,
      regionEnName: json['region_en_name'] ?? '',
      townshipEnName: json['township_en_name'] ?? '',
    );
  }
}
