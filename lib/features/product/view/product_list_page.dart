import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/product/view/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productNotifierProvider.notifier).getProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);

    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveTextSize() {
      if (screenWidth < 600) return 12;
      if (screenWidth <= 1100) return 16;
      return 25;
    }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const AppBarWidget(),
              Expanded(
                child: productListAsync.when(
                  data: (productListData) {
                    final productList = productListData?.data?.data ?? [];

                    if (productList.isEmpty) {
                      return const Center(
                        child: Text(
                          "No product available",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListView.builder(
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          final product = productList[index];
                          final productName = product.name ?? "";
                          final productImage = product.productImage ?? "";
                          final productType = product.productType ?? "";
                          final productId = product.id;

                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: productImage.isNotEmpty
                                    ? NetworkImage(productImage)
                                    : null,
                                backgroundColor: Colors.grey.shade300,
                              ),
                              title: Text(
                                productName,
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                  fontSize: responsiveTextSize(),
                                ),
                              ),
                              subtitle: Text(
                                productType,
                                style: GoogleFonts.poppins(
                                  fontSize: responsiveTextSize(),
                                  color: Colors.blue.shade700,
                                ),
                              ),

                              trailing: MaterialButton(
                                color: Colors.blue.shade500,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        productId: productId,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See Details',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (error, _) => const Center(
                    child: Text(
                      'Something went wrong',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  loading: () => const Center(
                    child: SpinKitCircle(size: 40, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarWidget extends ConsumerWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cartItemCountAsync = ref.watch(getTotalCartItemNotifierProvider);

    double responsiveTitle() {
      if (screenWidth < 600) return 18;
      if (screenWidth <= 1100) return 20;
      return 25;
    }

    double responsiveAppBarHeight() {
      if (screenWidth < 600) return 60;
      if (screenWidth <= 1100) return 70;
      return 80;
    }

    return Container(
      margin: const EdgeInsets.only(top: 18),
      height: responsiveAppBarHeight(),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'Products',
            style: GoogleFonts.poppins(
              fontSize: responsiveTitle(),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          Stack(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  // ignore: deprecated_member_use
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: responsiveTitle(),
                ),
              ),
              Positioned(
                top: 1,
                right: 3,
                child: cartItemCountAsync.when(
                  data: (count) => Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        count?.data.toString() ?? '0',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
