import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/home/widgets/brand_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/category_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/home_app_bar.dart';
import 'package:picoshop_theme2/features/home/widgets/product_preview.dart';
import 'package:picoshop_theme2/features/home/widgets/product_preview_slider.dart';
import 'package:picoshop_theme2/features/home/widgets/section_header.dart';
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

  void showToast(
    String message, {
    ToastificationType type = ToastificationType.info,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Icon? toastIcon;
      Color toastColor;

      switch (type) {
        case ToastificationType.success:
          toastIcon = Icon(Icons.check_circle_outline, color: Colors.green);
          toastColor = Colors.green.shade100;
          break;
        case ToastificationType.error:
          toastIcon = Icon(Icons.error_outline, color: Colors.red);
          toastColor = Colors.red.shade100;
          break;
        case ToastificationType.info:
        default:
          toastIcon = Icon(Icons.info_outline, color: Colors.blue);
          toastColor = Colors.blue.shade100;
          break;
      }

      toastification.show(
        title: Text(message),
        icon: toastIcon,
        showIcon: true,
        backgroundColor: toastColor,
        autoCloseDuration: const Duration(seconds: 1),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNextPageAll();
    });
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
      color: Colors.blue.shade400,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade500,
                  Colors.blue.shade200,
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
                        color: const Color.fromRGBO(158, 158, 158, 1),
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
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
                  const SizedBox(height: 12.0),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          SectionHeader("Brands", () {
                            context.go('/home/brandList');
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
                                // Inside your widget
                                if (brandList.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.storefront_outlined,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Brand list is currently unavailable.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return brandPreview(context, brandList);
                                }
                              },
                              error: (e, _) {
                                showToast(
                                  e.toString(),
                                  type: ToastificationType.error,
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
                            context.go('/home/categoryList');
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
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.storefront_outlined,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'category list is currently unavailable.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return categoryPreview(context, categoryList);
                                }
                              },
                              error: (e, _) {
                                showToast(
                                  e.toString(),
                                  type: ToastificationType.error,
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
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.storefront_outlined,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Product list is currently unavailable.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return productPreview(context, productList);
                                }
                              },
                              error: (e, _) {
                                showToast(
                                  e.toString(),
                                  type: ToastificationType.error,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
