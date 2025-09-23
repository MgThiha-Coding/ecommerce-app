class CategoriesListResponse {
  final bool success;
  final String message;
  final Data data;

  CategoriesListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoriesListResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}

class Data {
  final int currentPage;
  final List<CategoryDataModel> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final dynamic prevPageUrl;
  final int to;
  final int total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      currentPage: json['current_page'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => CategoryDataModel.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List<dynamic>? ?? [])
          .map((e) => Link.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '0') ?? 0,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

// Renamed Datum to CategoryDataModel
class CategoryDataModel {
  final int id;
  final String name;
  final dynamic shortCode;
  final int parentId;
  final dynamic description;
  final int createdBy;
  final int updatedBy;
  final dynamic deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryDataModel? parentCategory;
  final List<CategoryDataModel> childCategory;

  CategoryDataModel({
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
    required this.parentCategory,
    required this.childCategory,
  });

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoryDataModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortCode: json['short_code'],
      parentId: json['parent_id'] ?? 0,
      description: json['description'],
      createdBy: json['created_by'] ?? 0,
      updatedBy: json['updated_by'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      parentCategory: json['parent_category'] != null
          ? CategoryDataModel.fromJson(json['parent_category'])
          : null,
      childCategory: (json['child_category'] as List<dynamic>? ?? [])
          .map((e) => CategoryDataModel.fromJson(e))
          .toList(),
    );
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
