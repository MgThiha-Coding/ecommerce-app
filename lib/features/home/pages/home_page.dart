import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/brands/view/pages/brand_list_page.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/view/pages/category_list_page.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/home/widgets/brand_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/category_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/product_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/product_preview_slider.dart';
import 'package:picoshop_theme2/features/home/widgets/section_header.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:picoshop_theme2/features/search/view/search_page.dart';
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

  Widget _buildGlassCard({required Widget child, double borderRadius = 14}) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  // Error Widget
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 30,
            color: AppColors.emptyStateIcon,
          ),
          const SizedBox(height: 6),
          Text(
            'Something went wrong. Please try again later.',
            style: GoogleFonts.poppins(color: AppColors.emptyStateText),
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
    //final fonts = AppFonts(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundGradientStart,
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
                  child: Image.asset(AppImage.person, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${LocaleKeys.welcome.tr()} ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.appBarWelcomeText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.waving_hand,
                          color: AppColors.appBarWelcomeText,
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      ref.watch(userProvider)?.email ?? "Guest",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appBarEmailText,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            backgroundColor: Colors.white,
            onRefresh: _resetAll,
            child: ListView(
              controller: _scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 45,
                      child: AbsorbPointer(
                        child: TextField(
                          style: GoogleFonts.podkova(
                            fontSize: 15,
                            color: AppColors.searchText,
                            textStyle: const TextStyle(
                              fontFamilyFallback: ['Roboto', 'Arial'],
                            ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.searchFill,
                            hintText: "${LocaleKeys.search.tr()}..",
                            hintStyle: GoogleFonts.podkova(
                              color: AppColors.searchHint,
                              fontSize: 14,
                              textStyle: const TextStyle(
                                fontFamilyFallback: ['Roboto', 'Arial'],
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.searchIcon,
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
                              borderSide: BorderSide(
                                color: AppColors.searchBorder,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: AppColors.searchBorderFocused,
                                width: 2,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.welcomeToPicoShop.tr(),
                        style: GoogleFonts.poly(
                          color: AppColors.bannerTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          textStyle: const TextStyle(
                            fontFamilyFallback: ['Roboto', 'Arial'],
                          ),
                        ),
                      ),
                      Text(
                        LocaleKeys.caption.tr(),
                        style: GoogleFonts.podkova(
                          color: AppColors.bannerTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          textStyle: const TextStyle(
                            fontFamilyFallback: ['Roboto', 'Arial'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                _buildGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        SectionHeader(LocaleKeys.brand.tr(), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BrandListPage(),
                            ),
                          );
                        }),

                        SizedBox(
                          height: 40,
                          child: brandListAsync.when(
                            data: (brandList) => brandList.isEmpty
                                ? _buildEmptyState(
                                    'Brand list is currently unavailable.',
                                  )
                                : brandPreview(
                                    context,
                                    brandList.take(5).toList(),
                                  ),
                            loading: () => _buildShimmer(height: 80),
                            error: (error, _) =>
                                _buildEmptyState(error.toString()),
                          ),
                        ),

                        SectionHeader(LocaleKeys.category.tr(), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryListPage(),
                            ),
                          );
                        }),

                        SizedBox(
                          height: 70,
                          child: categoryListAsync.when(
                            data: (categoryList) => categoryList.isEmpty
                                ? _buildEmptyState(
                                    'Category list is currently unavailable.',
                                  )
                                : categoryPreview(
                                    context,
                                    categoryList.take(5).toList(),
                                  ),
                            loading: () => _buildShimmer(height: 110),
                            error: (error, _) =>
                                _buildEmptyState(error.toString()),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: ProductPreviewSlider(),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              LocaleKeys.availableProducts.tr(),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF3E5060),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 180,
                          child: productListAsync.when(
                            data: (productList) => productList.isEmpty
                                ? _buildEmptyState(
                                    'Product list is currently unavailable.',
                                  )
                                : productPreview(
                                    context,
                                    productList.take(5).toList(),
                                  ),
                            loading: () => _buildShimmer(height: 180),
                            error: (error, _) =>
                                _buildEmptyState(error.toString()),
                          ),
                        ),
                      ],
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

  // Shimmer Loading
  Widget _buildShimmer({required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(12),
        ),
        height: height,
        width: double.infinity,
      ),
    );
  }
}
