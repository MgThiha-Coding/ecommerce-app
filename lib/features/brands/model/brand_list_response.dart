class BrandListResponse {
  final bool success;
  final String message;
  final Data? data;

  BrandListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BrandListResponse.fromJson(Map<String, dynamic> json) => BrandListResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? Data.fromJson(json['data']) : null,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

class Data {
  final int currentPage;
  final List<BrandDataModel> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currentPage: json['current_page'] ?? 0,
        data: (json['data'] as List? ?? [])
            .map((e) => BrandDataModel.fromJson(e))
            .toList(),
        firstPageUrl: json['first_page_url'] ?? '',
        from: json['from'],
        lastPage: json['last_page'] ?? 0,
        lastPageUrl: json['last_page_url'] ?? '',
        links: (json['links'] as List? ?? [])
            .map((e) => Link.fromJson(e))
            .toList(),
        nextPageUrl: json['next_page_url'],
        path: json['path'] ?? '',
        perPage: json['per_page'] is int
            ? json['per_page']
            : int.tryParse(json['per_page']?.toString() ?? '0') ?? 0,
        prevPageUrl: json['prev_page_url'],
        to: json['to'],
        total: json['total'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': data.map((e) => e.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
        'links': links.map((e) => e.toJson()).toList(),
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total,
      };
}

class BrandDataModel {
  final int id;
  final String name;
  final String? description;
  final int? deletedBy;
  final int? createdBy;
  final int? updatedBy;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BrandDataModel({
    required this.id,
    required this.name,
    this.description,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandDataModel.fromJson(Map<String, dynamic> json) => BrandDataModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'],
        deletedBy: _parseInt(json['deleted_by']),
        createdBy: _parseInt(json['created_by']),
        updatedBy: _parseInt(json['updated_by']),
        deletedAt: _parseDate(json['deleted_at']),
        createdAt: _parseDate(json['created_at']),
        updatedAt: _parseDate(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'deleted_by': deletedBy,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json['url'],
        label: json['label']?.toString() ?? '',
        active: json['active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'active': active,
      };
}
