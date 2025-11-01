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

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final isMobile = fontSize.isMobile;

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
            duration: const Duration(seconds: 1),
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
                final price = product.defaultPrice ?? '0';
                final uom = product.uomName ?? 'Unit not specified';
                final stock =
                    (double.tryParse(product.stockSumCurrentQuantity ?? '0') ??
                            0)
                        .toInt();

                if (isMobile) {
                  // Mobile layout: keep exactly as original
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
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
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
                                    Colors.black.withOpacity(0.1),
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
                                  final parsedPrice =
                                      double.tryParse(price) ?? 0.0;
                                  final symbol =
                                      businessSetting?.currency.symbol ?? '';
                                  final decimalPlaces =
                                      businessSetting?.currencyDecimalPlaces ??
                                      2;
                                  return Text(
                                    '${parsedPrice.toStringAsFixed(decimalPlaces)}$symbol',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: fontSize.subHeading,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                },
                                loading: () => Text(price),
                                error: (_, __) => Text(price),
                              ),
                              const SizedBox(height: 16),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Tablet layout: left image, right details + Add To Cart
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child:
                                  productImage != null &&
                                      productImage.isNotEmpty
                                  ? Image.network(
                                      productImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Image.asset(AppImage.emptyContainer),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: GoogleFonts.poppins(
                                  fontSize: fontSize.heading,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              currency.when(
                                data: (businessSetting) {
                                  final parsedPrice =
                                      double.tryParse(price) ?? 0.0;
                                  final symbol =
                                      businessSetting?.currency.symbol ?? '';
                                  final decimalPlaces =
                                      businessSetting?.currencyDecimalPlaces ??
                                      2;
                                  return Text(
                                    '${parsedPrice.toStringAsFixed(decimalPlaces)}$symbol',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: fontSize.subHeading,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                },
                                loading: () => Text(price),
                                error: (_, __) => Text(price),
                              ),
                              const SizedBox(height: 16),
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
                                'Stock: $stock available',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: fontSize.body,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: AppButton(
                                      title: "Add To Cart",
                                      onTap: () {
                                        final variationId =
                                            product.productVariations != null &&
                                                product
                                                    .productVariations!
                                                    .isNotEmpty
                                            ? product
                                                  .productVariations!
                                                  .first
                                                  .variationId
                                            : null;
                                        if (variationId != null) {
                                          ref
                                              .read(
                                                addToCartNotifierProvider
                                                    .notifier,
                                              )
                                              .addToCart(
                                                AddToCartRequest(
                                                  productId: product.id!,
                                                  purchaseQty: itemCount,
                                                  variationId: variationId,
                                                ),
                                              );
                                          ref
                                              .read(
                                                cartNotifierProvider.notifier,
                                              )
                                              .fetchCart();
                                        }
                                      },
                                      backgroundColor: AppColors.primary,
                                      labelColor: AppColors.background,
                                      isLoading:
                                          ref
                                              .watch(addToCartNotifierProvider)
                                              .itemLoading[product.id] ==
                                          true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              error: (error, _) =>
                  _buildShimmerWithError(context, error, isMobile),
              loading: () => _buildShimmer(context, isMobile),
            ),
          ),
          if (isMobile)
            Expanded(flex: 2, child: _buildAddToCartSection(fontSize)),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildAddToCartSection(Responsive fontSize) {
    final productDetailAsync = ref.watch(productDetailNotifierProvider);
    final currency = ref.watch(businessSettingNotifierProvider);

    return Container(
      color: AppColors.background,
      child: productDetailAsync.when(
        data: (data) {
          if (data?.data == null) return const SizedBox.shrink();
          final product = data!.data!;
          final productId = product.id;

          final addToCartState = ref.watch(addToCartNotifierProvider);
          final isItemLoading = addToCartState.itemLoading[productId] == true;
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
                        final symbol = businessSetting?.currency.symbol ?? '';
                        final decimalPlaces =
                            businessSetting?.currencyDecimalPlaces ?? 2;
                        return Text(
                          '${totalPrice.toStringAsFixed(decimalPlaces)}$symbol',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: fontSize.subHeading,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                      loading: () => Text(totalPrice.toStringAsFixed(2)),
                      error: (_, __) => Text(totalPrice.toStringAsFixed(2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: AppButton(
                    title: "Add To Cart",
                    onTap: () {
                      final productDetail = ref
                          .read(productDetailNotifierProvider)
                          .value
                          ?.data;
                      if (productDetail != null) {
                        final variationId =
                            productDetail.productVariations != null &&
                                productDetail.productVariations!.isNotEmpty
                            ? productDetail.productVariations!.first.variationId
                            : null;
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
                          ref.read(cartNotifierProvider.notifier).fetchCart();
                        }
                      }
                    },
                    backgroundColor: AppColors.primary,
                    labelColor: AppColors.background,
                    isLoading: isItemLoading,
                  ),
                ),
              ),
            ],
          );
        },
        error: (err, _) => const SizedBox.shrink(),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context, bool isMobile) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile) {
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
      );
    } else {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(height: 300, color: Colors.grey.shade300),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: Column(
                  children: List.generate(
                    6,
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
      );
    }
  }

  Widget _buildShimmerWithError(
    BuildContext context,
    Object error,
    bool isMobile,
  ) {
    return Stack(
      children: [
        _buildShimmer(context, isMobile),
        Center(
          child: Text(
            'Failed to load product.\n$error',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: Responsive(context).body,
            ),
          ),
        ),
      ],
    );
  }
}
