import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/business_setting/viewmodel/business_setting_notifier.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
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
      final notifier = ref.read(productDetailNotifierProvider.notifier);
      notifier.reset();
      notifier.getProductDetail(widget.productId);
      ref.read(businessSettingNotifierProvider.notifier).fetchBusinessSetting();
    });
  }

  void increment() => setState(() => itemCount++);
  void decrement() {
    if (itemCount > 1) setState(() => itemCount--);
  }

  void refreshCartItem() {
    ref.read(totalCartNotifierProvider.notifier).refreshTotalCart();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final productDetailAsync = ref.watch(productDetailNotifierProvider);
    final currency = ref.watch(businessSettingNotifierProvider);

    ref.listen<AddToCartState>(addToCartNotifierProvider, (previous, next) {
      if (next.lastResponse != null &&
          next.lastResponse != previous?.lastResponse) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added To Cart Successfully',
              style: TextStyle(
                fontFamily: "Poppins",
                color: AppColors.textSecondary,
                fontSize: fontSize.body,
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.background,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
      }

      final errorMessage = next.itemError[widget.productId];
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(
                fontFamily: "Poppins",
                color: AppColors.error,
                fontSize: fontSize.body,
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.background,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 4,
        centerTitle: true,
        title: Text(
          'Product Details',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: fontSize.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: productDetailAsync.when(
              data: (data) {
                if (data?.data == null) {
                  return Center(
                    child: Text(
                      'No product details available.',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: fontSize.body,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                final product = data!.data!;
                final productImage = product.productImage;
                final productName = product.name ?? 'Unnamed Product';
                final productType = product.productType ?? 'Type not specified';
                final brandName =
                    product.brandName ?? 'Brand information not available';
                final categoryName =
                    product.categoryName ?? 'Category not specified';
                final price = product.defaultPrice ?? 'Price not available';
                final uom = product.uomName ?? 'Unit not specified';
                final stock =
                    (double.tryParse(product.stockSumCurrentQuantity ?? '0') ??
                            0)
                        .toInt();

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
                              child:
                                  productImage != null &&
                                      productImage.isNotEmpty
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
                            Text(
                              'Price',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: fontSize.subHeading,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            currency.when(
                              data: (businessSetting) {
                                if (price.isEmpty ||
                                    price == 'Price not available') {
                                  return Text(
                                    'Price not provided',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: fontSize.subHeading,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                }
                                final parsedPrice = double.tryParse(price);
                                if (parsedPrice == null) {
                                  return Text(
                                    price,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: fontSize.subHeading,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                }
                                if (businessSetting != null) {
                                  final symbol =
                                      businessSetting.currency.symbol;
                                  final decimalPlaces =
                                      businessSetting.currencyDecimalPlaces;
                                  final formattedPrice =
                                      '${parsedPrice.toStringAsFixed(decimalPlaces)}$symbol';
                                  return Text(
                                    formattedPrice,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: fontSize.subHeading,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                }
                                return Text(
                                  parsedPrice.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: fontSize.subHeading,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                              error: (_, __) => Text(price),
                              loading: () => Text(price),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Brand: $brandName',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Category: $categoryName',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Type: $productType',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'UOM: $uom',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Stock',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: fontSize.subHeading,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$stock available',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: fontSize.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (error, _) {
                final List<String> messages = [];
                if (error is String) {
                  messages.add(error);
                } else if (error is List)
                  // ignore: curly_braces_in_flow_control_structures
                  messages.addAll(error.map((e) => e.toString()));
                else
                  // ignore: curly_braces_in_flow_control_structures
                  messages.add("Something went wrong. Please try again.");

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: List.generate(
                                  5,
                                  (_) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
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
                                // ignore: deprecated_member_use
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
              },
              loading: () {
                final width = MediaQuery.of(context).size.width;
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: width,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 24,
                            width: width * 0.6,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 22,
                            width: width * 0.3,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 16,
                            width: width * 0.4,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 40,
                                width: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.background,
              child: productDetailAsync.when(
                data: (data) {
                  if (data?.data == null) return const SizedBox.shrink();
                  final product = data!.data!;
                  final productId = product.id;
                  final variationId =
                      product.productVariations != null &&
                          product.productVariations!.isNotEmpty
                      ? product.productVariations!.first.variationId
                      : null;
                  final addToCartState = ref.watch(addToCartNotifierProvider);
                  final isItemLoading =
                      addToCartState.itemLoading[productId] == true;
                  final priceString = product.defaultPrice ?? '0';
                  final price = double.tryParse(priceString) ?? 0.0;
                  final totalPrice = price * itemCount;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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

                            currency.when(
                              data: (businessSetting) {
                                final symbol =
                                    businessSetting?.currency.symbol ?? '';
                                final decimalPlaces =
                                    businessSetting?.currencyDecimalPlaces ?? 2;
                                final formattedTotalPrice =
                                    '${totalPrice.toStringAsFixed(decimalPlaces)}$symbol';
                                return Text(
                                  formattedTotalPrice,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: fontSize.subHeading,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                              loading: () =>
                                  Text(totalPrice.toStringAsFixed(2)),
                              error: (_, __) =>
                                  Text(totalPrice.toStringAsFixed(2)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        height: 45,
                        width: double.infinity,
                        child: AppButton(
                          title: "Add To Cart",
                          onTap: () {
                            if (variationId != null) {
                              ref
                                  .read(addToCartNotifierProvider.notifier)
                                  .addToCart(
                                    AddToCartRequest(
                                      productId: productId!,
                                      purchaseQty: itemCount,
                                      variationId: variationId,
                                    ),
                                  );
                              ref
                                  .read(cartNotifierProvider.notifier)
                                  .fetchCart();
                            }
                          },
                          backgroundColor: AppColors.primary,
                          labelColor: AppColors.background,
                          isLoading: isItemLoading,
                        ),
                      ),
                    ],
                  );
                },
                error: (err, _) => Center(child: Text(err.toString())),
                loading: () => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
