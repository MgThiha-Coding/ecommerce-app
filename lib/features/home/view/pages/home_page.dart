import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';
import 'package:picoshop_theme2/features/brands/view/brand_list_page.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/view/category_list_page.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/home/view/widgets/product_preview_slider.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                     getNextPageAll();
                  }
                  return false;
                },
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
                        MaterialPageRoute(
                          builder: (context) => BrandListPage(),
                        ),
                      );
                    }),
                    Container(
                      height: 90,
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
                              title: Text('No brand Available'),
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
      ),
    );
  }
}

Widget brandPreview(BuildContext context, List<BrandDataModel?> brandList) {
  return SizedBox(
    height: 70,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: brandList.length,
      itemBuilder: (context, index) {
        final brandName = brandList[index]?.name ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 60,
                width: 60,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: Center(
                  child: Text(
                    brandName,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(9),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Brand',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget categoryPreview(
  BuildContext context,
  List<CategoryDataModel?> categoryList,
) {
  return SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final categoryName = categoryList[index]?.name ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 90,
                width: 90,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: Center(
                  child: Text(
                    categoryName,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(17),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Category',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget productPreview(
  BuildContext context,
  List<ProductDataModel?> productList,
) {
  return SizedBox(
    height: 160,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final productName = productList[index]?.name ?? '';
        final productImage = productList[index]?.productImage ?? '';
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            height: 160,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: productImage.isEmpty
                          ? Image.asset(
                              AppImage.emptyContainer,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  SizedBox.expand(
                                    child: Image.asset(
                                      AppImage.emptyContainer,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      productName,
                      style: GoogleFonts.poppins(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

Widget SectionHeader(String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      margin: EdgeInsets.only(top: 18, bottom: 8),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          responsive.isMobile
              ? IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
                  ),
                )
              : SizedBox(width: 48),
          Text(
            'Pico Care',
            style: GoogleFonts.poppins(
              fontSize: responsive.value(mobile: 15, tablet: 20, desktop: 25),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
              size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
            ),
          ),
        ],
      ),
    );
  }
}
