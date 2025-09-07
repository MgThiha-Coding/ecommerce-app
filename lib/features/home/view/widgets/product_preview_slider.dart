/*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ProductPreviewSlider extends ConsumerStatefulWidget {
  const ProductPreviewSlider({super.key});

  @override
  ConsumerState<ProductPreviewSlider> createState() =>
      _ProductListSliderState();
}

class _ProductListSliderState extends ConsumerState<ProductPreviewSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final productListAsync = ref.watch(productNotifierProvider);

    return SizedBox(
      height: responsive.value(mobile: 130, tablet: 140, desktop: 210),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: productListAsync.when(
          data: (productListData) {
            final productList = productListData?.data?.data ?? [];
            if (productList.isEmpty) return ProductSliderLoading();

            return Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: productList.length,
                  itemBuilder: (context, index, realIndex) {
                    final product = productList[index];
                    final productName = product.name ?? '';
                    final productImage = product.productImage ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.grey[100],
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: productImage.isEmpty
                                    ? Container(color: Colors.grey[300])
                                    : Image.network(
                                        productImage,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(color: Colors.grey[300]),
                                      ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productName.isEmpty
                                        ? 'No Product'
                                        : productName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: GoogleFonts.poppins(
                                      fontSize: responsive.value(
                                          mobile: 9, tablet: 13, desktop: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    scrollPhysics: const BouncingScrollPhysics(),
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      productList.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.blue.shade500
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const ProductSliderLoading(),
          error: (error, _) => const ProductSliderLoading(),
        ),
      ),
    );
  }
}

class ProductSliderLoading extends StatelessWidget {
  const ProductSliderLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: responsive.value(mobile: 130, tablet: 200, desktop: 210),
          width: double.infinity,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
*/