import 'dart:convert';

/// To parse from JSON string
LocalTownshipResponse localTownshipResponseFromJson(String str) =>
    LocalTownshipResponse.fromJson(json.decode(str));

/// To encode to JSON string
String localTownshipResponseToJson(LocalTownshipResponse data) =>
    json.encode(data.toJson());

class LocalTownshipResponse {
  final bool success;
  final String message;
  final List<TownshipData>? data;

  LocalTownshipResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LocalTownshipResponse.fromJson(Map<String, dynamic> json) =>
      LocalTownshipResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List?)
            ?.map((e) => TownshipData.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.map((e) => e.toJson()).toList(),
      };
}

class TownshipData {
  final int id;
  final int regionId;
  final String mmName;
  final String enName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TownshipData({
    required this.id,
    required this.regionId,
    required this.mmName,
    required this.enName,
    this.createdAt,
    this.updatedAt,
  });

  factory TownshipData.fromJson(Map<String, dynamic> json) => TownshipData(
        id: json['id'] ?? 0,
        regionId: json['region_id'] ?? 0,
        mmName: json['mm_name'] ?? '',
        enName: json['en_name'] ?? '',
        createdAt: _parseDate(json['created_at']),
        updatedAt: _parseDate(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'region_id': regionId,
        'mm_name': mmName,
        'en_name': enName,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
