class ProductDetailResponse {
  bool? success;
  String? message;
  Data? data;

  ProductDetailResponse({this.success, this.message, this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class Data {
  String? name;
  int? id;
  String? productType;
  String? hasVariation;
  int? uomId;
  int? purchaseUomId;
  String? image;
  dynamic images;
  int? brandId;
  dynamic manufacturerId;
  int? categoryId;
  String? uomName;
  String? uomShortName;
  String? brandName;
  String? categoryName;
  String? stockSumCurrentQuantity;
  String? defaultPrice;
  String? productImage;
  String? purchaseUomName;
  List<ProductVariation>? productVariations;
  List<dynamic>? variationValues;
  Uom? uom;
  Brand? brand;
  Category? category;
  Uom? purchaseUom;

  Data({
    this.name,
    this.id,
    this.productType,
    this.hasVariation,
    this.uomId,
    this.purchaseUomId,
    this.image,
    this.images,
    this.brandId,
    this.manufacturerId,
    this.categoryId,
    this.uomName,
    this.uomShortName,
    this.brandName,
    this.categoryName,
    this.stockSumCurrentQuantity,
    this.defaultPrice,
    this.productImage,
    this.purchaseUomName,
    this.productVariations,
    this.variationValues,
    this.uom,
    this.brand,
    this.category,
    this.purchaseUom,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      name: json['name'] as String?,
      id: json['id'] as int?,
      productType: json['product_type'] as String?,
      hasVariation: json['has_variation'] as String?,
      uomId: json['uom_id'] as int?,
      purchaseUomId: json['purchase_uom_id'] as int?,
      image: json['image'] as String?,
      images: json['images'],
      brandId: json['brand_id'] as int?,
      manufacturerId: json['manufacturer_id'],
      categoryId: json['category_id'] as int?,
      uomName: json['uom_name'] as String?,
      uomShortName: json['uom_short_name'] as String?,
      brandName: json['brand_name'] as String?,
      categoryName: json['category_name'] as String?,
      stockSumCurrentQuantity: json['stock_sum_current_quantity'] as String?,
      defaultPrice: json['default_price'] as String?,
      productImage: json['product_image'] as String?,
      purchaseUomName: json['purchase_uom_name'] as String?,
      productVariations: json['product_variations'] != null
          ? (json['product_variations'] as List)
              .map((e) => ProductVariation.fromJson(e))
              .toList()
          : null,
      variationValues: json['variation_values'] != null
          ? List<dynamic>.from(json['variation_values'])
          : null,
      uom: json['uom'] != null ? Uom.fromJson(json['uom']) : null,
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      purchaseUom: json['purchase_uom'] != null ? Uom.fromJson(json['purchase_uom']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
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
        'default_price': defaultPrice,
        'product_image': productImage,
        'purchase_uom_name': purchaseUomName,
        'product_variations': productVariations?.map((e) => e.toJson()).toList(),
        'variation_values': variationValues,
        'uom': uom?.toJson(),
        'brand': brand?.toJson(),
        'category': category?.toJson(),
        'purchase_uom': purchaseUom?.toJson(),
      };
}

class ProductVariation {
  int? variationId; // Fix: maps from JSON 'id'
  int? productId;
  String? variationSku;
  dynamic variationTemplateValueId;
  String? defaultPurchasePrice;
  String? defaultSellingPrice;
  Product? product;

  ProductVariation({
    this.variationId,
    this.productId,
    this.variationSku,
    this.variationTemplateValueId,
    this.defaultPurchasePrice,
    this.defaultSellingPrice,
    this.product,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      variationId: json['id'] as int?, // FIXED
      productId: json['product_id'] as int?,
      variationSku: json['variation_sku'] as String?,
      variationTemplateValueId: json['variation_template_value_id'],
      defaultPurchasePrice: json['default_purchase_price'] as String?,
      defaultSellingPrice: json['default_selling_price'] as String?,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': variationId, // FIXED
        'product_id': productId,
        'variation_sku': variationSku,
        'variation_template_value_id': variationTemplateValueId,
        'default_purchase_price': defaultPurchasePrice,
        'default_selling_price': defaultSellingPrice,
        'product': product?.toJson(),
      };
}

class Product {
  String? productDescription;
  String? productImage;

  Product({this.productDescription, this.productImage});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productDescription: json['product_description'] as String?,
      productImage: json['product_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_description': productDescription,
        'product_image': productImage,
      };
}

class Brand {
  int? id;
  String? name;

  Brand({this.id, this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Uom {
  int? id;
  String? name;
  String? shortName;

  Uom({this.id, this.name, this.shortName});

  factory Uom.fromJson(Map<String, dynamic> json) {
    return Uom(
      id: json['id'] as int?,
      name: json['name'] as String?,
      shortName: json['short_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
      };
}
