import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
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

  // Error Widget
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
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        //actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
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
                      ref.watch(userProvider)?.email ?? "Guest",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: Responsive(context).body,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: _resetAll,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              controller: _scrollController,
              children: [
                // SearchBar
                const SearchBar(),

                // Brand Preview Section Header & BrandList
                SectionHeader(LocaleKeys.brand.tr(), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrandListPage(),
                    ),
                  );
                }),
                SizedBox(
                  height: 55,
                  child: brandListAsync.when(
                    data: (brandList) => brandList.isEmpty
                        ? _buildEmptyState(
                            'Brand list is currently unavailable.',
                          )
                        : brandPreview(context, brandList.take(5).toList()),
                    loading: () => _buildShimmer(height: 80),
                    error: (error, _) => _buildEmptyState(error.toString()),
                  ),
                ),

                // Categories Preview & CategoryList
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
                    error: (error, _) => _buildEmptyState(error.toString()),
                  ),
                ),

                // Featured Product Slider
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: ProductPreviewSlider(),
                ),

                // Product Preview Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      LocaleKeys.availableProducts.tr(),
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
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
                        : productPreview(context, productList.take(5).toList()),
                    loading: () => _buildShimmer(height: 180),
                    error: (error, _) => _buildEmptyState(error.toString()),
                  ),
                ),

                // space
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          height: 48,
          child: AbsorbPointer(
            child: TextField(
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: fontSize.caption,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: "Search",
                hintStyle: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: fontSize.body,
                ),
                prefixIcon: const Icon(Icons.search),
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
