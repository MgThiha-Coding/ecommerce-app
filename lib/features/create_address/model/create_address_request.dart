
class CreateAddressRequest {
  final String type;
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String addressLine2;
  final int regionId;
  final int townshipId;
  final String postalZipCode;
  final String phone;

  CreateAddressRequest({
    required this.type,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    required this.addressLine2,
    required this.regionId,
    required this.townshipId,
    required this.postalZipCode,
    required this.phone,
  });

  factory CreateAddressRequest.fromJson(Map<String, dynamic> json) {
    return CreateAddressRequest(
      type: json['name'] ?? '', 
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      regionId: json['region_id'] ?? 0,
      townshipId: json['township_id'] ?? 0,
      postalZipCode: json['postal_zip_code'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': type, 
      'first_name': firstName,
      'last_name': lastName,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'region_id': regionId,
      'township_id': townshipId,
      'postal_zip_code': postalZipCode,
      'phone': phone,
    };
  }
}
