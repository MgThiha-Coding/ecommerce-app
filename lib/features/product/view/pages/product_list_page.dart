import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:shimmer/shimmer.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNextIfNeeded();
    });

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        await Future.delayed(const Duration(milliseconds: 500));
        ref.read(productNotifierProvider.notifier).getNextPage();
      }
    });
  }

  Future<void> _fetchNextIfNeeded() async {
    final notifier = ref.read(productNotifierProvider.notifier);
    await notifier.getNextPage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent == 0 &&
          !notifier.isNoMore) {
        _fetchNextIfNeeded();
      }
    });
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(productNotifierProvider.notifier);
    await notifier.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNextIfNeeded();
    });
  }

  Widget _buildGlassCard({required Widget child, double borderRadius = 0}) {
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

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          LocaleKeys.availableProducts.tr(),
          style: GoogleFonts.poppins(
            fontSize: responsive.value(mobile: 15, tablet: 20, desktop: 25),
            color: AppColors.background,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search,color: Colors.white,))
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            backgroundColor: Colors.blue.shade50,
            onRefresh: _onRefresh,
            child: _buildGlassCard(
              child: productListAsync.when(
                loading: () => _productGridShimmer(context),
                error: (error, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.grey[200],
                        content: Text(
                          error.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  });
                  return const SizedBox.shrink();
                },
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'Product list is currently unavailable.',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(6),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: responsive.isMobile ? 3 : 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1 / 1.4,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductDetailPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: product.productImage?.isNotEmpty == true
                                      ? SizedBox.expand(
                                          child: Image.network(
                                            product.productImage!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Image.asset(
                                                  AppImage.emptyContainer,
                                                  fit: BoxFit.cover,
                                                ),
                                          ),
                                        )
                                      : SizedBox.expand(
                                          child: Image.asset(
                                            AppImage.emptyContainer,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product.name ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  GridView _productGridShimmer(BuildContext context, {int itemCount = 15}) {
    final responsive = Responsive(context);
    return GridView.builder(
      itemCount: itemCount,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(6),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isMobile ? 3 : 5,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        childAspectRatio: 1 / 1.2,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
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
      ),
    );
  }
}
