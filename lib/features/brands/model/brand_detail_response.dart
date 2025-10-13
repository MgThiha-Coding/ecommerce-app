class BrandDetailResponse {
  final bool success;
  final String message;
  final Data data;

  BrandDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BrandDetailResponse.fromJson(Map<String, dynamic> json) {
    return BrandDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}

class Data {
  final int id;
  final String name;
  final dynamic description;
  final dynamic deletedBy;
  final int createdBy;
  final dynamic updatedBy;
  final dynamic deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Data({
    required this.id,
    required this.name,
    required this.description,
    required this.deletedBy,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      deletedBy: json['deleted_by'],
      createdBy: json['created_by'] ?? 0,
      updatedBy: json['updated_by'],
      deletedAt: json['deleted_at'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
