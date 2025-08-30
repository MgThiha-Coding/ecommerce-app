

class AddToCartRequest {
  final int productId;
  final int purchaseQty;
  final int variationId;

  AddToCartRequest({
    required this.productId,
    required this.purchaseQty,
    required this.variationId
  });

  
}