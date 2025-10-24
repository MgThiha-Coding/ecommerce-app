import 'dart:convert';

/// To parse the JSON string into a LocalRegionResponse object
LocalRegionResponse localRegionResponseFromJson(String str) =>
    LocalRegionResponse.fromJson(json.decode(str));

/// To convert a LocalRegionResponse object to a JSON string
String localRegionResponseToJson(LocalRegionResponse data) =>
    json.encode(data.toJson());

class LocalRegionResponse {
  final bool? success;
  final String? message;
  final RegionData? data;

  LocalRegionResponse({
    this.success,
    this.message,
    this.data,
  });

  factory LocalRegionResponse.fromJson(Map<String, dynamic> json) =>
      LocalRegionResponse(
        success: json["success"] as bool?,
        message: json["message"] as String?,
        data: json["data"] == null
            ? null
            : RegionData.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class RegionData {
  final int? currentPage;
  final List<RegionItem>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  RegionData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) => RegionData(
        currentPage: json["current_page"] as int?,
        data: (json["data"] as List<dynamic>?)
            ?.map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        firstPageUrl: json["first_page_url"] as String?,
        from: json["from"] as int?,
        lastPage: json["last_page"] as int?,
        lastPageUrl: json["last_page_url"] as String?,
        links: (json["links"] as List<dynamic>?)
            ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageUrl: json["next_page_url"] as String?,
        path: json["path"] as String?,
        perPage: json["per_page"] is int
            ? json["per_page"] as int
            : int.tryParse(json["per_page"].toString()),
        prevPageUrl: json["prev_page_url"] as String?,
        to: json["to"] as int?,
        total: json["total"] as int?,
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data?.map((e) => e.toJson()).toList(),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links?.map((e) => e.toJson()).toList(),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class RegionItem {
  final int? id;
  final String? mmName;
  final String? enName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RegionItem({
    this.id,
    this.mmName,
    this.enName,
    this.createdAt,
    this.updatedAt,
  });

  factory RegionItem.fromJson(Map<String, dynamic> json) => RegionItem(
        id: json["id"] as int?,
        mmName: json["mm_name"] as String?,
        enName: json["en_name"] as String?,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mm_name": mmName,
        "en_name": enName,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"] as String?,
        label: json["label"] as String?,
        active: json["active"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
