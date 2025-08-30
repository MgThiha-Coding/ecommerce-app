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
    Future.microtask(() {
      if (widget.productId != null) {
        ref
            .read(productDetailNotifierProvider.notifier)
            .getProductDetail(widget.productId!);
      }
    });
  }

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    setState(() {
      if (quantity > 0) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productDetailAsync = ref.watch(productDetailNotifierProvider);

    ref.listen<AsyncValue<AddToCartResponse?>>(addToCartNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (response) {
          if (response != null && response.success == true) {
            final productName =
                response.data?.cartItem?.productFullName ?? 'Product';
            final count = response.data!.itemsCount;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '($count) $productName added to cart',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
                backgroundColor: Colors.white,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        loading: () {},
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                err.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey[700],
              duration: const Duration(seconds: 2),
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade900,
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Expanded(
                    child: productDetailAsync.when(
                      data: (productDetailData) {
                        if (productDetailData?.data != null) {
                          final productDetailImage =
                              productDetailData!.data!.productImage ?? "";
                          final description = productDetailData
                              .data
                              ?.productVariations
                              ?.first
                              .product
                              ?.productDescription;

                          final variationId = productDetailData
                              .data!
                              .productVariations
                              ?.first
                              .variationId;

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: productDetailImage.isNotEmpty
                                      ? Image.network(
                                          productDetailImage,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    height: 300,
                                                    color: Colors.grey.shade300,
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      'Image not provided',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                        )
                                      : Container(
                                          height: 300,
                                          color: Colors.grey.shade300,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Image not provided',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade100,
                                                  shape: const CircleBorder(),
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  decrement();
                                                },
                                                icon: Icon(
                                                  Icons.remove,
                                                  color: Colors.blue.shade700,
                                                  size: 20,
                                                ),
                                              ),
                                              // Quantity Display
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 7,
                                                    ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.blue.shade300,
                                                  ),
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
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade100,
                                                  shape: const CircleBorder(),
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  increment();
                                                },
                                                icon: Icon(
                                                  Icons.add,
                                                  color: Colors.blue.shade700,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),

                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    addToCartNotifierProvider
                                                        .notifier,
                                                  )
                                                  .addtoCart(
                                                    AddToCartRequest(
                                                      productId:
                                                          widget.productId!,
                                                      purchaseQty: quantity,
                                                      variationId: variationId!,
                                                    ),
                                                  );

                                              ref.read(getTotalCartItemNotifierProvider.notifier).getTotalCartItem();
                                            },
                                            child: Text(
                                              'Add to Cart',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        productDetailData.data!.name ??
                                            "No Name",
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ProductDescriptionWidget(
                                        htmlDescription: description,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(child: Text('No data available'));
                        }
                      },
                      loading: () => const Center(
                        child: SpinKitCircle(size: 50, color: Colors.white),
                      ),
                      error: (error, _) => const Center(
                        child: Center(
                          child: Text('Something went wrong\nPlease try again'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
