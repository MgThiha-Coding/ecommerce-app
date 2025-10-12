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
    // Reset all lists
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
                            const Icon(
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
                            color: Colors.black87,
                            textStyle: const TextStyle(
                              fontFamilyFallback: ['Roboto', 'Arial'],
                            ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Search...",
                            hintStyle: GoogleFonts.podkova(
                              color: Colors.grey[500],
                              fontSize: 15,
                              textStyle: const TextStyle(
                                fontFamilyFallback: ['Roboto', 'Arial'],
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF27AE60),
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
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF2ECC71),
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
                        'All your favourite is here',
                        style: GoogleFonts.poly(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          textStyle: const TextStyle(
                            fontFamilyFallback: ['Roboto', 'Arial'],
                          ),
                        ),
                      ),
                      Text(
                        'Explore your special moment',
                        style: GoogleFonts.podkova(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          textStyle: const TextStyle(
                            fontFamilyFallback: ['Roboto', 'Arial'],
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Get Order Now',
                          style: GoogleFonts.podkova(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            textStyle: const TextStyle(
                              fontFamilyFallback: ['Roboto', 'Arial'],
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          backgroundColor: const Color(0xFFFFC107),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 2,
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
                        SectionHeader("Brands", () {
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

                        SectionHeader("Categories", () {
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
                              'Available Products',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2ECC71),
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
