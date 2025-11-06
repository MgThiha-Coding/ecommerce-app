class AddressResponse {
  final bool success;
  final String message;
  final List<AddressItem> data;

  AddressResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <AddressItem>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };

  AddressResponse copyWith({
    bool? success,
    String? message,
    List<AddressItem>? data,
  }) {
    return AddressResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  String toString() =>
      'AddressResponse(success: $success, message: $message, data: ${data.length} items)';
}

class AddressItem {
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
  final int isDefault; 
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String regionEnName;
  final String townshipEnName;

  AddressItem({
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
    required this.createdAt,
    required this.updatedAt,
    required this.regionEnName,
    required this.townshipEnName,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    DateTime? tryParseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return AddressItem(
      id: json['id'] as int,
      contactId: json['contact_id'] as int,
      name: (json['name'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      addressLine1: (json['address_line_1'] as String?) ?? '',
      addressLine2: (json['address_line_2'] as String?) ?? '',
      townshipId: json['township_id'] as int,
      regionId: json['region_id'] as int,
      postalZipCode: (json['postal_zip_code'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      isDefault: json['is_default'] is int
          ? json['is_default'] as int
          : int.tryParse('${json['is_default']}') ?? 0,
      createdAt: tryParseDate(json['created_at']),
      updatedAt: tryParseDate(json['updated_at']),
      regionEnName: (json['region_en_name'] as String?) ?? '',
      townshipEnName: (json['township_en_name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'contact_id': contactId,
    'name': name,
    'first_name': firstName,
    'last_name': lastName,
    'address_line_1': addressLine1,
    'address_line_2': addressLine2,
    'township_id': townshipId,
    'region_id': regionId,
    'postal_zip_code': postalZipCode,
    'country': country,
    'phone': phone,
    'is_default': isDefault,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
    'region_en_name': regionEnName,
    'township_en_name': townshipEnName,
  };

  AddressItem copyWith({
    int? id,
    int? contactId,
    String? name,
    String? firstName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    int? townshipId,
    int? regionId,
    String? postalZipCode,
    String? country,
    String? phone,
    int? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? regionEnName,
    String? townshipEnName,
  }) {
    return AddressItem(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      townshipId: townshipId ?? this.townshipId,
      regionId: regionId ?? this.regionId,
      postalZipCode: postalZipCode ?? this.postalZipCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      regionEnName: regionEnName ?? this.regionEnName,
      townshipEnName: townshipEnName ?? this.townshipEnName,
    );
  }

  @override
  String toString() =>
      'AddressItem(id: $id, name: $name, firstName: $firstName, lastName: $lastName)';
}
