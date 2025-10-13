class CategoryDetailResponse {
  final bool success;
  final String message;
  final Data data;

  CategoryDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return CategoryDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}

class Data {
  final int id;
  final String name;
  final dynamic shortCode;
  final dynamic parentId;
  final dynamic description;
  final int createdBy;
  final int updatedBy;
  final dynamic deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Data({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.parentId,
    required this.description,
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
      shortCode: json['short_code'],
      parentId: json['parent_id'],
      description: json['description'],
      createdBy: json['created_by'] ?? 0,
      updatedBy: json['updated_by'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
