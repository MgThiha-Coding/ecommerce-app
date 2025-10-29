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
import 'package:picoshop_theme2/features/brands/view/pages/brand_list_page.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/view/pages/category_list_page.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/home/widgets/brand_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/category_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/product_preview_slider.dart';
import 'package:picoshop_theme2/features/home/widgets/section_header.dart';
import 'package:picoshop_theme2/features/order_history/view/order_history_list_page.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_list_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:picoshop_theme2/features/search/view/pages/search_page.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getNextPageAll();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _getNextPageAll();
      }
    });
  }

  Future<void> _resetAll() async {
    await Future.wait([
      ref.read(brandListNotifierProvider.notifier).reset(),
      ref.read(categoryListNotifierProvider.notifier).reset(),
      ref.read(productNotifierProvider.notifier).reset(),
    ]);

    _getNextPageAll();
  }

  void _getNextPageAll() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      await Future.wait([
        ref.read(brandListNotifierProvider.notifier).getNextPage(),
        ref.read(categoryListNotifierProvider.notifier).getNextPage(),
        ref.read(productNotifierProvider.notifier).getNextPage(),
      ]);
    } finally {
      _isFetching = false;
    }
  }

  // Empty Widget
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 30,
            color: AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            'Something went wrong. Please try again later.',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: Responsive(context).body,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandListAsync = ref.watch(brandListNotifierProvider);
    final categoryListAsync = ref.watch(categoryListNotifierProvider);
    final productListAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      /*
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Consumer(
          builder: (context, ref, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  child: Image.asset(AppImage.appLogo, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${LocaleKeys.welcome.tr()} ',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: Responsive(context).body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Icon(
                              Icons.waving_hand,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                        Text(
                          ref.watch(userProvider)?.name ?? "Guest",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: Responsive(context).subHeading,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      */
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: CircleAvatar(
                radius: 18,
                child: Image.asset(AppImage.appLogo, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: SearchBar()),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryListPage(),
                    ),
                  );
                },
                icon: const Icon(LineIcons.shoppingBag),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // ignore: deprecated_member_use
              colors: [
                Colors.white, // top
                Colors.blue.withOpacity(0.15), // subtle middle
                Colors.blue.withOpacity(0.05), // bottom very light
              ],
            ),
          ),
          child: Stack(
            children: [
              RefreshIndicator(
                backgroundColor: Colors.white,
                onRefresh: _resetAll,
                child: Padding(
                  padding: Responsive(context).isMobile
                      ? const EdgeInsets.all(6.0)
                      : const EdgeInsets.all(16),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 6),
                    children: [
                      const ProductPreviewSlider(),
                      // Brand Section
                      sectionHeader(
                        Responsive(context),
                        LocaleKeys.brand.tr(),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BrandListPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 40,
                        child: brandListAsync.when(
                          data: (brandList) => brandList.isEmpty
                              ? _buildEmptyState(
                                  'Brand list is currently unavailable.',
                                )
                              : brandPreview(
                                  context,
                                  brandList.take(16).toList(),
                                ),
                          loading: () => _buildShimmer(height: 80),
                          error: (error, _) =>
                              _buildEmptyState(error.toString()),
                        ),
                      ),

                      // Category Section
                      sectionHeader(
                        Responsive(context),
                        LocaleKeys.category.tr(),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryListPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 60,
                        child: categoryListAsync.when(
                          data: (categoryList) => categoryList.isEmpty
                              ? _buildEmptyState(
                                  'Category list is currently unavailable.',
                                )
                              : categoryPreview(
                                  context,
                                  categoryList.take(16).toList(),
                                ),
                          loading: () => _buildShimmer(height: 110),
                          error: (error, _) =>
                              _buildEmptyState(error.toString()),
                        ),
                      ),

                      // Available Product Sections
                      sectionHeader(
                        Responsive(context),
                        LocaleKeys.availableProducts.tr(),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductListPage(),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 7,
                        ),
                        child: productListAsync.when(
                          data: (productList) {
                            if (productList.isEmpty) {
                              return _buildEmptyState(
                                'Product list is currently unavailable.',
                              );
                            }
                            final previewList = productList.take(20).toList();
                            return MasonryGridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: Responsive(context).isMobile
                                  ? 2
                                  : 4,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              itemCount: previewList.length,
                              itemBuilder: (context, index) {
                                final product = previewList[index];
                                final productId = product.id;
                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailPage(productId!),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                          child: Image.network(
                                            product.productImage ??
                                                AppImage.emptyContainer,
                                            fit: BoxFit.cover,
                                            height: (index % 2 == 0)
                                                ? 130
                                                : 190,
                                            width: double.infinity,
                                            errorBuilder: (_, __, ___) =>
                                                Image.asset(
                                                  AppImage.emptyContainer,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),

                                              Text(
                                                product.productType.toString(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.priceLabelColor,
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
                            );
                          },
                          loading: () => _buildShimmer(height: 200),
                          error: (error, _) =>
                              _buildEmptyState(error.toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky Float SearchBar
              /*
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Responsive(context).isMobile
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: SearchBar(),
                        ),
                      )
                    : const SizedBox(height: 55, child: SearchBar()),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer Loading

  Widget _buildShimmer({required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: AppColors.background,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        height: height,
        width: double.infinity,
      ),
    );
  }
}

// SearchBar
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: SizedBox(
          height: 44,
          child: AbsorbPointer(
            child: TextField(
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: fontSize.caption,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: LocaleKeys.search.tr(),
                hintStyle: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: fontSize.body,
                  color: AppColors.textPrimary,
                ),
                prefixIcon: const Icon(
                  LineIcons.search,
                  color: AppColors.textPrimary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
