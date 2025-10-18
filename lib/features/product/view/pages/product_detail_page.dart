import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailPage(this.productId, {super.key});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int itemCount = 1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productDetailNotifierProvider.notifier)
          .getProductDetail(widget.productId);
    });
  }

  void increment() {
    setState(() {
      itemCount++;
    });
  }

  void decrement() {
    if (itemCount > 1) {
      setState(() {
        itemCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final productDetailAsync = ref.watch(productDetailNotifierProvider);
    final addToCartAsync = ref.watch(addToCartNotifierProvider);

    ref.listen<AsyncValue<AddToCartResponse?>>(addToCartNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (data) {
          if (data != null &&
              data.message != null &&
              data.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data.message!),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        loading: () {},
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 4,
        centerTitle: true,
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
            fontSize: fontSize.subHeading,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: productDetailAsync.when(
        data: (data) {
          if (data?.data == null) {
            return Center(
              child: Text(
                'No product details available.',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: fontSize.body,
                ),
              ),
            );
          }

          final product = data!.data!;
          final productImage = product.productImage;
          final productName = product.name ?? '';
          final productType = product.productType ?? '';
          final brandName = product.brandName ?? '';
          final categoryName = product.categoryName ?? '';
          final price = product.defaultPrice ?? '';
          final uom = product.uomName ?? '';
          final stock = product.stockSumCurrentQuantity ?? '';
          final productId = product.id;
          final variationId =
              product.productVariations != null &&
                  product.productVariations!.isNotEmpty
              ? product.productVariations!.first.variationId
              : null;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: productImage != null && productImage.isNotEmpty
                            ? Image.network(
                                productImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  AppImage.emptyContainer,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Image.asset(
                                AppImage.emptyContainer,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // ignore: deprecated_member_use
                            Colors.black.withOpacity(0.1),
                            // ignore: deprecated_member_use
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        productName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: fontSize.heading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _buildTag('Brand: $brandName'),
                          _buildTag('Category: $categoryName'),
                          _buildTag('Type: $productType'),
                          _buildTag('UOM: $uom'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Price',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize.subHeading,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        price.isEmpty ? "No Price Provided" : price,
                        style: GoogleFonts.poppins(
                          fontSize: fontSize.subHeading,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Stock',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize.subHeading,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$stock available',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: const CircleBorder(),
                            ),
                            onPressed: decrement,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              itemCount.toString(),
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: fontSize.subHeading,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: const CircleBorder(),
                            ),
                            onPressed: increment,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: AppButton(
                          title: "Add To Cart",
                          onTap: () {
                            if (variationId != null) {
                              ref
                                  .read(addToCartNotifierProvider.notifier)
                                  .addtoCart(
                                    AddToCartRequest(
                                      productId: productId!,
                                      purchaseQty: itemCount,
                                      variationId: variationId,
                                    ),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Product variation not available",
                                  ),
                                ),
                              );
                            }
                          },
                          backgroundColor: AppColors.primary,
                          labelColor: AppColors.background,
                          isLoading: addToCartAsync.isLoading ? true : false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, _) => errorOverShimmer(error: error),
        loading: () => _loadingShimmer(context),
      ),
    );
  }
Widget errorOverShimmer({required dynamic error}) {
  final List<String> messages = [];
  if (error is String) {
    messages.add(error);
  } else if (error is List) {
    messages.addAll(error.map((e) => e.toString()));
  } else {
    messages.add("Something went wrong. Please try again.");
  }

  return Stack(
    children: [
     
      Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 300, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(
                    5,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: messages.map((msg) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}

  Widget _loadingShimmer(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: width, // Square
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Product title placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 24,
                width: width * 0.6,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 12),
            // Tags placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: List.generate(4, (_) {
                  return Container(
                    height: 20,
                    width: width * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Price placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 22,
                width: width * 0.3,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 12),
            // Stock placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 16,
                width: width * 0.4,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            // Quantity selector placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(height: 40, width: 40, color: Colors.grey.shade300),
                  const SizedBox(width: 12),
                  Container(height: 40, width: 60, color: Colors.grey.shade300),
                  const SizedBox(width: 12),
                  Container(height: 40, width: 40, color: Colors.grey.shade300),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Button placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
      ),
    );
  }
}
