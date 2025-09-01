import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/cart/model/request/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/response/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/product/view/product_description_widget.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int? productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.productId != null) {
        ref.read(productDetailNotifierProvider.notifier).getProductDetail(widget.productId!);
      }
    });
  }

  void increment() {
    setState(() => quantity++);
  }

  void decrement() {
    setState(() {
      if (quantity > 1) quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productDetailAsync = ref.watch(productDetailNotifierProvider);

    // Snackbar listener for AddToCart
    ref.listen<AsyncValue<AddToCartResponse?>>(addToCartNotifierProvider, (prev, next) {
      next.when(
        data: (response) {
          if (response != null && response.success == true) {
            final productName = response.data?.cartItem?.productFullName ?? 'Product';
            final itemCount = response.data?.itemsCount;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$itemCount $productName added to cart',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
                backgroundColor: Colors.white,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        loading: () {},
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                err.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade900,
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: productDetailAsync.when(
            data: (productDetailData) {
              final product = productDetailData?.data;
              if (product == null) {
                return const Center(child: Text("No data available"));
              }

              final productDetailImage = product.productImage ?? "";
              final description = product.productVariations?.first.product?.productDescription;
              final variationId = product.productVariations?.first.variationId;

              return SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: productDetailImage.isNotEmpty
                            ? Image.network(
                                productDetailImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) => Container(
                                  height: 300,
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: const Text("Image not provided"),
                                ),
                              )
                            : Container(
                                height: 300,
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: const Text("Image not provided"),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: decrement,
                                      icon: const Icon(Icons.remove, size: 20),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.blue.shade100,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade300),
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: increment,
                                      icon: const Icon(Icons.add, size: 20),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.blue.shade100,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  onPressed: variationId == null
                                      ? null
                                      : () {
                                          ref.read(addToCartNotifierProvider.notifier).addtoCart(
                                                AddToCartRequest(
                                                  productId: widget.productId!,
                                                  purchaseQty: quantity,
                                                  variationId: variationId,
                                                ),
                                              );
                                          ref.read(getTotalCartItemNotifierProvider.notifier).getTotalCartItem();
                                        },
                                  child: Text(
                                    "Add to Cart",
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product.name ?? "No Name",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ProductDescriptionWidget(htmlDescription: description),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: SpinKitCircle(size: 50, color: Colors.white)),
            error: (_, __) => const Center(child: Text("Something went wrong\nPlease try again")),
          ),
        ),
      ),
    );
  }
}
