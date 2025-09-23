import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

class ProductPreviewSlider extends ConsumerWidget {
  const ProductPreviewSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productListAsync = ref.watch(productNotifierProvider);

    return SizedBox(
      height: 80,
      width: double.infinity,
      child: productListAsync.when(
        data: (productList) {
          if (productList.isEmpty)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 30, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'featured is currently unavailable.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );

          return CarouselSlider.builder(
            itemCount: productList.length,
            itemBuilder: (context, index, realIndex) {
              final product = productList[index];
              final productName = product.name ?? '';
              final productImage = product.productImage ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: productImage.isEmpty
                            ? Image.asset(
                                AppImage.emptyContainer,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                productImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      AppImage.emptyContainer,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                      ),
                      if (productName.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              productName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 80,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              scrollPhysics: const BouncingScrollPhysics(),
            ),
          );
        },
        loading: () => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 80,
            color: Colors.grey.shade300,
          ),
        ),
        error: (error, _) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 80,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
