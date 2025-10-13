
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

class ProductHiveModel {
  final int? id;
  final String? name;
  final String? productImage;

  ProductHiveModel({required this.id, required this.name, required this.productImage});

  factory ProductHiveModel.fromDataModel(ProductDataModel data) {
    return ProductHiveModel(
      id: data.id,
      name: data.name,
      productImage: data.productImage ?? data.image,
    );
  }

  ProductDataModel toDataModel() {
    return ProductDataModel(
      id: id,
      name: name,
      productType: null,
      hasVariation: null,
      uomId: null,
      purchaseUomId: null,
      image: productImage,
      images: null,
      brandId: null,
      manufacturerId: null,
      categoryId: null,
      uomName: null,
      uomShortName: null,
      brandName: null,
      categoryName: null,
      stockSumCurrentQuantity: null,
      productImage: productImage,
      purchaseUomName: null,
      uom: null,
      brand: null,
      category: null,
      purchaseUom: null,
      variations: null,
    );
  }
}
