import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(brandListNotifierProvider.notifier).getBrandList();
      ref.read(categoriesListNotifierProvider.notifier).getCagetoryList();
      ref.read(productNotifierProvider.notifier).getProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveTextSize() {
      if (screenWidth < 600) {
        return 12;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 16;
      }
      return 25;
    }

    double responsiveBrandListHeight() {
      if (screenWidth < 600) {
        return 70;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 70;
      }
      return 80;
    }

    double responsiveBrandContainerSize() {
      if (screenWidth < 600) {
        return 40;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 70;
      }
      return 80;
    }

    final brandListAsync = ref.watch(brandListNotifierProvider);
    final categoriesListAsync = ref.watch(categoriesListNotifierProvider);
    final productListAsync = ref.watch(productNotifierProvider);
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                AppBarWidget(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Brands',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveTextSize(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveTextSize(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // BrandList
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  child: Container(
                    height: responsiveBrandListHeight() + 10,
                    padding: EdgeInsets.all(2),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: brandListAsync.when(
                      data: (brandListData) {
                        final brandList = brandListData?.data.data ?? [];
                        if (brandList.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: brandList.length,
                          itemBuilder: (context, index) {
                            final brandName = brandList[index].name;

                            return Container(
                              margin: EdgeInsets.all(3),
                              height: responsiveBrandContainerSize(),
                              width: responsiveBrandContainerSize() + 30,
                              child: Card(
                                child: Stack(
                                  children: [
                                    // Main card
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Text(
                                          brandName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: responsiveTextSize(),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Brands',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      error: (error, _) {
                        return Center(
                          child: Text(
                            'Something went wrong\n Please try again later.',
                          ),
                        );
                      },
                      loading: () {
                        return Center(
                          child: SpinKitCircle(size: 60, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveTextSize(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveTextSize(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  child: Container(
                    height: responsiveBrandListHeight() + 50,
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: categoriesListAsync.when(
                      data: (categoryListData) {
                        final categoryList = categoryListData?.data.data ?? [];
                        if (categoryList.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            final categoryName = categoryList[index].name;
                            return Card(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                height: responsiveBrandContainerSize() + 20,
                                width: responsiveBrandContainerSize() + 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      categoryName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: responsiveTextSize(),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: SizedBox(
                                        height: responsiveTextSize() + 15,
                                        child: ElevatedButton(
                                          onPressed: () {},

                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade500,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'View',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize:
                                                  responsiveTextSize() - 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      error: (error, _) {
                        return Center(
                          child: Text(
                            'Something went wrong\n Please try again later.',
                          ),
                        );
                      },
                      loading: () {
                        return Center(
                          child: SpinKitCircle(size: 60, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Products',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveTextSize(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveTextSize(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: productListAsync.when(
                      data: (productListData) {
                        final productList = productListData?.data?.data ?? [];

                        if (productList.isEmpty) {
                          return Center(
                            child: SizedBox.shrink()
                          );
                        }

                        // Limit number of items displayed
                        final displayCount = productList.length > 4
                            ? 4
                            : productList.length;

                        return Column(
                          children: List.generate(displayCount, (index) {
                            final product = productList[index];
                            final productName = product.name ?? "";
                            final productImage = product.productImage ?? "";
                            final productType = product.productType ?? "";

                            return Container(
                              margin: EdgeInsets.only(bottom: 2),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: Row(
                                  children: [
                                    // Product image
                                    ClipRRect(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(10),
                                      ),
                                      child: Image.network(
                                        productImage,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // Product details
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: responsiveTextSize(),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              productType,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize:
                                                    responsiveTextSize() - 2,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.green,
                                        size: responsiveTextSize(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                      error: (error, _) => Center(
                        child: Text(
                          'Something went wrong\nPlease try again later.',
                          style: GoogleFonts.poppins(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      loading: () => Center(
                        child: SpinKitCircle(
                          size: 60,
                          color: Colors.blue.shade900,
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
    );
  }
}

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveTitle() {
      if (screenWidth < 600) {
        return 18;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 20;
      }
      return 25;
    }

    double responsiveAppBarHeight() {
      if (screenWidth < 600) {
        return 60;
      } else if (screenWidth >= 600 && screenWidth <= 1100) {
        return 70;
      }
      return 80;
    }

    return Container(
      margin: EdgeInsets.only(top: 18),
      height: responsiveAppBarHeight(),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
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
              size: responsiveTitle(),
            ),
          ),
          Text(
            'Pico Care',
            style: GoogleFonts.poppins(
              fontSize: responsiveTitle(),
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
              size: responsiveTitle(),
            ),
          ),
        ],
      ),
    );
  }
}
