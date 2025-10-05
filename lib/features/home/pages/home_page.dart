import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
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
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

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
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(brandListNotifierProvider.notifier).reset();
    ref.read(categoryListNotifierProvider.notifier).reset();
    ref.read(productNotifierProvider.notifier).reset();
  }

  void _getNextPageAll() {
    ref.read(brandListNotifierProvider.notifier).getNextPage();
    ref.read(categoryListNotifierProvider.notifier).getNextPage();
    ref.read(productNotifierProvider.notifier).getNextPage();
  }

  Widget _buildGlassCard({required Widget child, double borderRadius = 14}) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white,
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
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // AppBar Section
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
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
                              "Welcome ",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.waving_hand,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ],
                        ),
                        Text(
                          ref.watch(userProvider)?.email ?? "Guest",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          body: RefreshIndicator(
            backgroundColor: Colors.amber.shade100,
            onRefresh: _resetAll,
            child: ListView(
              controller: _scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 6,
                  ),
                  child: Text(
                    'Featured',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ProductPreviewSlider(),
                ),

                const SizedBox(height: 12),

                _buildGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        SectionHeader("Brands", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BrandListPage(),
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
                                : brandPreview(context, brandList),
                            loading: () => _buildShimmer(height: 80),
                            error: (error, _) =>
                                _buildEmptyState(error.toString()),
                          ),
                        ),

                        SectionHeader("Categories", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryListPage(),
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
                                : categoryPreview(context, categoryList),
                            loading: () => _buildShimmer(height: 110),
                            error: (error, _) =>
                                _buildEmptyState(error.toString()),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Available Products',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF2ECC71),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 300,
                          child: productListAsync.when(
                            data: (productList) => productList.isEmpty
                                ? _buildEmptyState(
                                    'Product list is currently unavailable.',
                                  )
                                : productPreview(context, productList),
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
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        height: height,
        width: double.infinity,
      ),
    );
  }
}
