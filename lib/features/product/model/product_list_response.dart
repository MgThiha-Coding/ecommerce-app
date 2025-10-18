class ProductListResponse {
  final bool? success;
  final String? message;
  final ProductPageData? data;

  ProductListResponse({this.success, this.message, this.data});

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
  final List<ProductDataModel> data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ProductPageData({
    this.currentPage,
    List<ProductDataModel>? data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    List<PageLink>? links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  })  : data = data ?? [],
        links = links ?? [];

  factory ProductPageData.fromJson(Map<String, dynamic> json) {
    return ProductPageData(
      currentPage: json['current_page'] as int?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => ProductDataModel.fromJson(e))
              .toList()
          : [],
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      links: json['links'] != null
          ? (json['links'] as List).map((e) => PageLink.fromJson(e)).toList()
          : [],
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

class PageLink {
  final String? url;
  final String? label;
  final bool? active;

  PageLink({this.url, this.label, this.active});

  factory PageLink.fromJson(Map<String, dynamic> json) => PageLink(
        url: json['url'] as String?,
        label: json['label'] as String?,
        active: json['active'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'active': active,
      };
}

class Variation {
  final int? id;

  Variation({this.id});

  factory Variation.fromJson(Map<String, dynamic> json) => Variation(
        id: json['id'] as int?,
      );

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
  final List<String> images;
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
  final List<Variation> variations;

  ProductDataModel({
    this.id,
    this.name,
    this.productType,
    this.hasVariation,
    this.uomId,
    this.purchaseUomId,
    this.image,
    List<String>? images,
    this.brandId,
    this.manufacturerId,
    this.categoryId,
    this.uomName,
    this.uomShortName,
    this.brandName,
    this.categoryName,
    this.stockSumCurrentQuantity,
    this.productImage,
    this.purchaseUomName,
    this.uom,
    this.brand,
    this.category,
    this.purchaseUom,
    List<Variation>? variations,
  })  : images = images ?? [],
        variations = variations ?? [];

  factory ProductDataModel.fromJson(Map<String, dynamic> json) {
    return ProductDataModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      productType: json['product_type'] as String?,
      hasVariation: json['has_variation'] as String?,
      uomId: json['uom_id'] as int?,
      purchaseUomId: json['purchase_uom_id'] as int?,
      image: json['image'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
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
          : [],
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
        'variations': variations.map((e) => e.toJson()).toList(),
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
    this.id,
    this.name,
    this.shortName,
    this.unitCategoryId,
    this.unitType,
    this.value,
    this.roundedAmount,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Uom.fromJson(Map<String, dynamic> json) => Uom(
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
        deletedAt: (json['deleted_at'] is String && json['deleted_at'].isNotEmpty)
            ? DateTime.parse(json['deleted_at'])
            : null,
        createdAt: (json['created_at'] is String && json['created_at'].isNotEmpty)
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: (json['updated_at'] is String && json['updated_at'].isNotEmpty)
            ? DateTime.parse(json['updated_at'])
            : null,
      );

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
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Brand({this.id, this.name, this.description, this.image, this.createdAt, this.updatedAt});

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class Category {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({this.id, this.name, this.description, this.image, this.createdAt, this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class PurchaseUom {
  final int? id;
  final String? name;
  final String? shortName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseUom({this.id, this.name, this.shortName, this.createdAt, this.updatedAt});

  factory PurchaseUom.fromJson(Map<String, dynamic> json) => PurchaseUom(
        id: json['id'] as int?,
        name: json['name'] as String?,
        shortName: json['short_name'] as String?,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
