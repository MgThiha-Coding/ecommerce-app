import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/cart/view/pages/cart_page.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingCartButton = false;
  int? _selectedCategoryId;

 @override
void initState() {
  super.initState();
  _scrollController.addListener(() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return; // <-- check widget still exists
      ref.read(productNotifierProvider.notifier).getNextPage();
    }
  });
}

  Future<void> _onRefresh() async {
    final productNotifier = ref.read(productNotifierProvider.notifier);
    await productNotifier.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent == 0 &&
          !productNotifier.isNoMore) {
        productNotifier.getNextPage();
      }
    });
  }

  void _onCategorySelected(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    final productNotifier = ref.read(productNotifierProvider.notifier);
    if (categoryId == null) {
      productNotifier.setFilters({});
    } else {
      productNotifier.setFilters({'category_id': categoryId});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    final categoriesAsync = ref.watch(categoryListNotifierProvider);
    final productsAsync = ref.watch(productNotifierProvider);

    ref.listen<AddToCartState>(addToCartNotifierProvider, (previous, next) {
      if (next.lastResponse != null &&
          next.lastResponse != previous?.lastResponse) {
        setState(() => _showFloatingCartButton = true);
        Future.delayed(const Duration(seconds: 20), () {
          if (mounted) setState(() => _showFloatingCartButton = false);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.availableProducts.tr(),
          style: GoogleFonts.poppins(
            fontSize: fontSize.subHeading,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories
          SizedBox(
            height: 50,
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (categories) => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _categoryChip(null, 'All');
                  }
                  final category = categories[index - 1];
                  return _categoryChip(category.id, category.name);
                },
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.textSecondary,
              backgroundColor: AppColors.background,
              onRefresh: _onRefresh,
              child: Stack(
                children: [
                  productsAsync.when(
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
                      return productListView(
                          context, _scrollController, products, fontSize);
                    },
                  ),

                  if (_showFloatingCartButton)
                    floatingCartButton(context, fontSize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(int? id, String label) {
    final isSelected = id == _selectedCategoryId || (id == null && _selectedCategoryId == null);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onCategorySelected(id),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget productListView(
      BuildContext context,
      ScrollController scrollController,
      List<ProductDataModel> products,
      Responsive fontSize) {
    final isMobile = Responsive(context).isMobile;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 20, vertical: isMobile ? 0 : 10),
      child: GridView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : 5,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final productId = product.id;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(productId!)),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: SizedBox(
                      height: isMobile ? 130 : 150,
                      width: double.infinity,
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
                          product.brandName ?? "Brand not provided",
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.caption,
                            color: AppColors.brandLabelColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.name ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize.body,
                            fontWeight: isMobile ? FontWeight.w600 : FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
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

  Widget floatingCartButton(BuildContext context, Responsive fontSize) {
    return Positioned(
      bottom: 17,
      left: 10,
      right: 10,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.background.withOpacity(0.8)],
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
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
                  child: const Icon(Icons.shopping_cart_checkout, color: AppColors.background, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'View Cart',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: fontSize.subHeading,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: fontSize.subHeading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GridView _productGridShimmer(BuildContext context, {int itemCount = 10}) {
    final responsive = Responsive(context);
    return GridView.builder(
      itemCount: itemCount,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isTablet ? 5 : responsive.isDesktop ? 5 : 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: responsive.isMobile ? 1 / 1.5 : 1 / 1.3,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
