import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/home/view/widgets/home_appbar.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(productNotifierProvider.notifier).getNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);
    final notifier = ref.read(productNotifierProvider.notifier);

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
          child: Column(
            children: [
              const HomeAppBar(),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: Colors.blue.shade50,
                  onRefresh: () => notifier.reset(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        notifier.getNextPage();
                      }
                      return false;
                    },
                    child: productListAsync.when(
                      loading: () => productGridShimmer(context),
                      error: (e, _) {
                        toastification.show(
                          title: Text(e.toString()),
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Colors.white,
                        );
                        return const SizedBox.shrink();
                      },
                      data: (products) {
                        if (products.isEmpty) {
                          toastification.show(
                            title: const Text(
                              'No Product Availble right now...',
                            ),
                            autoCloseDuration: const Duration(seconds: 3),
                            backgroundColor: Colors.white,
                          );
                          return const SizedBox.shrink();
                        }
                        return productList(
                          context,
                          products,
                          notifier.isNoMore,
                          _scrollController,
                        );
                      },
                    ),
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

GridView productList(
  BuildContext context,
  List<ProductDataModel?> products,
  bool isNoMore,
  ScrollController _scrollController,
) {
  final responsive = Responsive(context);
  return GridView.builder(
    controller: _scrollController,
    itemCount: products.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: responsive.isMobile ? 3 : 5,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1 / 1.2,
    ),
    itemBuilder: (context, index) {
      final productName = products[index]?.name ?? '';
      final productImage = products[index]?.productImage ?? '';
      return GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox.expand(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
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
  );
}

GridView productGridShimmer(BuildContext context, {int itemCount = 15}) {
  final responsive = Responsive(context);
  return GridView.builder(
    itemCount: itemCount,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: responsive.isMobile ? 3 : 5,
      mainAxisSpacing: 7,
      crossAxisSpacing: 7,
      childAspectRatio: 1 / 1.2,
    ),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                  child: Container(color: Colors.grey.shade300),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
