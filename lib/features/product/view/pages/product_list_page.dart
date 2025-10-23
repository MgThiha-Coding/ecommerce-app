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

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);
    final fontSize = Responsive(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          LocaleKeys.availableProducts.tr(),
          style: GoogleFonts.poppins(
            fontSize: fontSize.subHeading,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          child: productListAsync.when(
            loading: () => _productGridShimmer(context),
            error: (error, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.grey[100],
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
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: fontSize.isMobile ? 8 : 20,
                  vertical: fontSize.isMobile ? 6 : 10,
                ),
                child: GridView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive(context).isMobile? 3 : 4 ,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: fontSize.isMobile ? 1 / 1.6 : 1 / 1.4,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final productId = products[index].id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: product.productImage?.isNotEmpty == true
                                    ? Image.network(
                                        product.productImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
                                              AppImage.emptyContainer,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                      )
                                    : Image.asset(
                                        AppImage.emptyContainer,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: fontSize.body,
                                      fontWeight: Responsive(context).isMobile? FontWeight.w600:FontWeight.w400,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: fontSize.isMobile ? 3 : 5),
                                  Text(
                                    'Brand ${product.brandName ?? ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: fontSize.caption,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    product.productType ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: fontSize.caption,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: fontSize.isMobile ? 6 : 10),
                                  SizedBox(
                                    height: Responsive(context).isMobile? 25 : 30,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProductDetailPage(productId!),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Text(
                                        'See Detail',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: fontSize.caption,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isTablet
            ? 3
            : responsive.isDesktop
            ? 5
            : 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: responsive.isMobile ? 1 / 1.5 : 1 / 1.3,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
