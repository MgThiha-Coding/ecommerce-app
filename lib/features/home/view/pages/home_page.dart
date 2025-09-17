import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/brands/view/brand_list_page.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/view/pages/category_list_page.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/home/view/widgets/brand_preview.dart';
import 'package:picoshop_theme2/features/home/view/widgets/category_preview.dart';
import 'package:picoshop_theme2/features/home/view/widgets/product_preview.dart';
import 'package:picoshop_theme2/features/home/view/widgets/product_preview_slider.dart';
import 'package:picoshop_theme2/features/home/view/widgets/section_header.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_list_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

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
    getNextPageAll();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        getNextPageAll();
      }
    });
  }

  Future<void> resetAll() async {
    await Future.delayed(Duration(milliseconds: 500));
    ref.read(brandListNotifierProvider.notifier).reset();
    ref.read(categoryListNotifierProvider.notifier).reset();
    ref.read(productNotifierProvider.notifier).reset();
  }

  Future<void> getNextPageAll() async {
    ref.read(brandListNotifierProvider.notifier).getNextPage();
    ref.read(categoryListNotifierProvider.notifier).getNextPage();
    ref.read(productNotifierProvider.notifier).getNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final brandListAsync = ref.watch(brandListNotifierProvider);
    final categoryListAsync = ref.watch(categoryListNotifierProvider);
    final productListAsync = ref.watch(productNotifierProvider);

    return Container(
      color: Colors.blue.shade500,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade500,
                  Colors.blue.shade100,
                ],
              ),
            ),
            child: RefreshIndicator(
              backgroundColor: Colors.blue.shade50,
              onRefresh: () => resetAll(),
              child: ListView(
                controller: _scrollController,
                children: [
                  HomeAppBar(),
                  TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Featured',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  ProductPreviewSlider(),
                  SectionHeader("Brands", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BrandListPage()),
                    );
                  }),
                  Container(
                    height: 80,
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: brandListAsync.when(
                      data: (brandList) {
                        if (brandList.isEmpty) {
                          toastification.show(
                            title: Text('No brand Available'),
                            autoCloseDuration: const Duration(seconds: 3),
                            backgroundColor: Colors.white,
                          );
                          return const SizedBox.shrink();
                        } else {
                          return brandPreview(context, brandList);
                        }
                      },
                      error: (e, _) {
                        toastification.show(
                          title: Text(e.toString()),
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Colors.white,
                        );
                        return const SizedBox.shrink();
                      },
                      loading: () => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
                  Container(
                    height: 110,
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: categoryListAsync.when(
                      data: (categoryList) {
                        if (categoryList.isEmpty) {
                          toastification.show(
                            title: Text('No category Available'),
                            autoCloseDuration: const Duration(seconds: 3),
                            backgroundColor: Colors.white,
                          );
                          return const SizedBox.shrink();
                        } else {
                          return categoryPreview(context, categoryList);
                        }
                      },
                      error: (e, _) {
                        toastification.show(
                          title: Text(e.toString()),
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Colors.white,
                        );
                        return const SizedBox.shrink();
                      },
                      loading: () => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SectionHeader("Products", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(),
                      ),
                    );
                  }),
                  Container(
                    height: 180,
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: productListAsync.when(
                      data: (productList) {
                        if (productList.isEmpty) {
                          toastification.show(
                            title: Text('No products Available'),
                            autoCloseDuration: const Duration(seconds: 3),
                            backgroundColor: Colors.white,
                          );
                          return const SizedBox.shrink();
                        } else {
                          return productPreview(context, productList);
                        }
                      },
                      error: (e, _) {
                        toastification.show(
                          title: Text(e.toString()),
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Colors.white,
                        );
                        return const SizedBox.shrink();
                      },
                      loading: () => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
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
}
