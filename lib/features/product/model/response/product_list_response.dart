class ProductListResponse {
  final bool? success;
  final String? message;
  final ProductPageData? data;

  ProductListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? ProductPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class ProductPageData {
  final int? currentPage;
  final List<ProductDataModel>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<PageLink>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ProductPageData({
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

  factory ProductPageData.fromJson(Map<String, dynamic> json) {
    return ProductPageData(
      currentPage: json['current_page'] as int?,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => ProductDataModel.fromJson(e)).toList()
          : null,
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      links: json['links'] != null
          ? (json['links'] as List).map((e) => PageLink.fromJson(e)).toList()
          : null,
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
      total: json['total'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': data?.map((e) => e.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
        'links': links?.map((e) => e.toJson()).toList(),
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total,
      };
}

class PageLink {
  final String? url;
  final String? label;
  final bool? active;

  PageLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'] as String?,
      label: json['label'] as String?,
      active: json['active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'active': active,
      };
}

class Variation {
  final int? id;

  Variation({required this.id});

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class ProductDataModel {
  final int? id;
  final String? name;
  final String? productType;
  final String? hasVariation;
  final int? uomId;
  final int? purchaseUomId;
  final String? image;
  final List<String>? images;
  final int? brandId;
  final int? manufacturerId;
  final int? categoryId;
  final String? uomName;
  final String? uomShortName;
  final String? brandName;
  final String? categoryName;
  final String? stockSumCurrentQuantity;
  final String? productImage;
  final String? purchaseUomName;
  final Uom? uom;
  final Brand? brand;
  final Category? category;
  final PurchaseUom? purchaseUom;
  final List<Variation>? variations;

  ProductDataModel({
    required this.id,
    required this.name,
    required this.productType,
    required this.hasVariation,
    required this.uomId,
    required this.purchaseUomId,
    required this.image,
    required this.images,
    required this.brandId,
    required this.manufacturerId,
    required this.categoryId,
    required this.uomName,
    required this.uomShortName,
    required this.brandName,
    required this.categoryName,
    required this.stockSumCurrentQuantity,
    required this.productImage,
    required this.purchaseUomName,
    required this.uom,
    required this.brand,
    required this.category,
    required this.purchaseUom,
    required this.variations,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      productType: json['product_type'] as String?,
      hasVariation: json['has_variation'] as String?,
      uomId: json['uom_id'] as int?,
      purchaseUomId: json['purchase_uom_id'] as int?,
      image: json['image'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      brandId: json['brand_id'] as int?,
      manufacturerId: json['manufacturer_id'] as int?,
      categoryId: json['category_id'] as int?,
      uomName: json['uom_name'] as String?,
      uomShortName: json['uom_short_name'] as String?,
      brandName: json['brand_name'] as String?,
      categoryName: json['category_name'] as String?,
      stockSumCurrentQuantity: json['stock_sum_current_quantity'] as String?,
      productImage: json['product_image'] as String?,
      purchaseUomName: json['purchase_uom_name'] as String?,
      uom: json['uom'] != null ? Uom.fromJson(json['uom']) : null,
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      purchaseUom: json['purchase_uom'] != null ? PurchaseUom.fromJson(json['purchase_uom']) : null,
      variations: json['variations'] != null
          ? (json['variations'] as List).map((e) => Variation.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'product_type': productType,
        'has_variation': hasVariation,
        'uom_id': uomId,
        'purchase_uom_id': purchaseUomId,
        'image': image,
        'images': images,
        'brand_id': brandId,
        'manufacturer_id': manufacturerId,
        'category_id': categoryId,
        'uom_name': uomName,
        'uom_short_name': uomShortName,
        'brand_name': brandName,
        'category_name': categoryName,
        'stock_sum_current_quantity': stockSumCurrentQuantity,
        'product_image': productImage,
        'purchase_uom_name': purchaseUomName,
        'uom': uom?.toJson(),
        'brand': brand?.toJson(),
        'category': category?.toJson(),
        'purchase_uom': purchaseUom?.toJson(),
        'variations': variations?.map((e) => e.toJson()).toList(),
      };
}

class Uom {
  final int? id;
  final String? name;
  final String? shortName;
  final int? unitCategoryId;
  final String? unitType;
  final String? value;
  final String? roundedAmount;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Uom({
    required this.id,
    required this.name,
    required this.shortName,
    required this.unitCategoryId,
    required this.unitType,
    required this.value,
    required this.roundedAmount,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Uom.fromJson(Map<String, dynamic> json) {
    return Uom(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortName: json['short_name'] as String?,
      unitCategoryId: json['unit_category_id'] as int?,
      unitType: json['unit_type'] as String?,
      value: json['value'] as String?,
      roundedAmount: json['rounded_amount'] as String?,
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      deletedBy: json['deleted_by']?.toString(),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
        'unit_category_id': unitCategoryId,
        'unit_type': unitType,
        'value': value,
        'rounded_amount': roundedAmount,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'deleted_by': deletedBy,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class Brand {
  final int? id;
  final String? name;
  final String? description;
  final String? deletedBy;
  final int? createdBy;
  final String? updatedBy;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Brand({
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

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      deletedBy: json['deleted_by']?.toString(),
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by']?.toString(),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

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
}

class Category {
  final int? id;
  final String? name;
  final String? shortCode;
  final int? parentId;
  final String? description;
  final int? createdBy;
  final int? updatedBy;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
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

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortCode: json['short_code'] as String?,
      parentId: json['parent_id'] as int?,
      description: json['description'] as String?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_code': shortCode,
        'parent_id': parentId,
        'description': description,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class PurchaseUom {
  final int? id;
  final String? name;
  final String? shortName;
  final int? unitCategoryId;
  final String? unitType;
  final String? value;
  final String? roundedAmount;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseUom({
    required this.id,
    required this.name,
    required this.shortName,
    required this.unitCategoryId,
    required this.unitType,
    required this.value,
    required this.roundedAmount,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseUom.fromJson(Map<String, dynamic> json) {
    return PurchaseUom(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortName: json['short_name'] as String?,
      unitCategoryId: json['unit_category_id'] as int?,
      unitType: json['unit_type'] as String?,
      value: json['value'] as String?,
      roundedAmount: json['rounded_amount'] as String?,
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      deletedBy: json['deleted_by']?.toString(),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
        'unit_category_id': unitCategoryId,
        'unit_type': unitType,
        'value': value,
        'rounded_amount': roundedAmount,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'deleted_by': deletedBy,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
