import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingCartButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        await Future.delayed(const Duration(milliseconds: 500));
        ref.read(productNotifierProvider.notifier).getNextPage();
      }
    });
  }

  Future<void> _fetchNextIfNeeded() async {
    final notifier = ref.read(productNotifierProvider.notifier);
    await notifier.getNextPage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent == 0 &&
          !notifier.isNoMore) {
        _fetchNextIfNeeded();
      }
    });
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(productNotifierProvider.notifier);
    await notifier.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNextIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);
    final fontSize = Responsive(context);
    ref.listen<AddToCartState>(addToCartNotifierProvider, (previous, next) {
      if (next.lastResponse != null &&
          next.lastResponse != previous?.lastResponse) {
        setState(() => _showFloatingCartButton = true);
        Future.delayed(const Duration(seconds: 12), () {
          if (mounted) setState(() => _showFloatingCartButton = false);
        });
      }
    });

    return Container(
      color: Colors.blue.withOpacity(0.3),
      child: SafeArea(
        child: Scaffold(
          // backgroundColor: AppColors.background,
          /*
          appBar: AppBar(
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            elevation: 0,
            centerTitle: true,
            title: Text(
              LocaleKeys.availableProducts.tr(),
              style: GoogleFonts.poppins(
                fontSize: fontSize.subHeading,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          */
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.withOpacity(0.3), Colors.white],
              ),
            ),
            child: RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              child: Stack(
                children: [
                  productListAsync.when(
                    loading: () => _productGridShimmer(context),
                    error: (error, _) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.grey[100],
                            content: Text(
                              error.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.blueGrey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      });
                      return const SizedBox.shrink();
                    },
                    data: (products) {
                      // Empty Widget
                      if (products.isEmpty) {
                        return Center(
                          child: Text(
                            'Product list is currently unavailable.',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w300,
                              fontSize: fontSize.body,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      // Product List
                      return productListView(
                        context,
                        _scrollController,
                        products,
                        fontSize,
                      );
                    },
                  ),

                  // FloatingCartButton
                  if (_showFloatingCartButton)
                    floatingCartButton(context, fontSize),

                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        height: 36,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.availableProducts.tr(),
                              style: GoogleFonts.poppins(
                                fontSize: fontSize.body,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            //Icon(LineIcons.shoppingBag,size: fontSize.heading,)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget productListView(
    BuildContext context,
    ScrollController scrollController,
    List<ProductDataModel> products,
    Responsive fontSize,
  ) {
    final isMobile = Responsive(context).isMobile;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 20,
        vertical: isMobile ? 6 : 10,
      ),
      child: MasonryGridView.count(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        crossAxisCount: isMobile ? 2 : 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final productId = product.id;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(productId!),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: product.productImage?.isNotEmpty == true
                        ? Image.network(
                            product.productImage!,
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            product.brandName ?? "Brand not provided",
                            style: GoogleFonts.poppins(
                              fontSize: fontSize.caption,
                              color: AppColors.brandLabelColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          product.name ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.body,
                            fontWeight: isMobile
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        Text(
                          '12000 MMK',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.caption,
                            color: AppColors.priceLabelColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        /*
                        SizedBox(
                          height: isMobile ? 35 : 30,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(productId!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'See Detail',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: fontSize.caption,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        */
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /*
  Widget productListView(
    BuildContext context,
    ScrollController scrollController,
    List<ProductDataModel> products,
    Responsive fontSize,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize.isMobile ? 2 : 20,
        vertical: fontSize.isMobile ? 6 : 10,
      ),
      child: GridView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive(context).isMobile ? 2 : 4,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: fontSize.isMobile ? 1 / 1.6 : 1 / 1.4,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          final productId = products[index].id;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: product.productImage?.isNotEmpty == true
                          ? Image.network(
                              product.productImage!,
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.body,
                            fontWeight: Responsive(context).isMobile
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: fontSize.isMobile ? 3 : 5),
                        Text(
                          'Brand ${product.brandName ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.caption,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.productType ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.caption,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: fontSize.isMobile ? 6 : 10),
                        SizedBox(
                          height: Responsive(context).isMobile ? 35 : 30,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(productId!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'See Detail',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: fontSize.caption,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  */

  // FloatingCartButton
  Widget floatingCartButton(BuildContext context, Responsive fontSize) {
    return Positioned(
      bottom: 17,
      left: 16,
      right: 16,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.textSecondary,
              AppColors.textSecondary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_checkout,
                    color: AppColors.background,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'View Cart',
                  style: GoogleFonts.poppins(
                    color: AppColors.background,
                    fontSize: fontSize.subHeading,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.background,
                  size: fontSize.subHeading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GridView _productGridShimmer(BuildContext context, {int itemCount = 15}) {
    final responsive = Responsive(context);
    return GridView.builder(
      itemCount: itemCount,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isTablet
            ? 3
            : responsive.isDesktop
            ? 5
            : 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: responsive.isMobile ? 1 / 1.5 : 1 / 1.3,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
