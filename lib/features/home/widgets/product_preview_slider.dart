import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';

class BrandPreviewSlider extends ConsumerStatefulWidget {
  const BrandPreviewSlider({super.key});

  @override
  ConsumerState<BrandPreviewSlider> createState() => _BrandPreviewSliderState();
}

class _BrandPreviewSliderState extends ConsumerState<BrandPreviewSlider> {
  int _currentIndex = 0; 

  @override
  Widget build(BuildContext context) {
    final brandListAsync = ref.watch(brandListNotifierProvider);

    return SizedBox(
      height: 115,
      width: double.infinity,
      child: brandListAsync.when(
        data: (brandList) {
          if (brandList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Featured is currently unavailable.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          final displayList = brandList.take(10).toList();

          return Column(
            children: [
              CarouselSlider.builder(
                itemCount: displayList.length,
                itemBuilder: (context, index, realIndex) {
                  final name = displayList[index].name ?? "Unnamed Brand";
                  final description =
                      displayList[index].description ??
                      "No description available";

                  return Card(
                    color: AppColors.background,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: Responsive(context).subHeading,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: Responsive(context).body,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Image.asset(AppImage.appLogo, scale: 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 90,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(seconds: 1),
                  autoPlayCurve: Curves.easeInOut,
                  scrollPhysics: const BouncingScrollPhysics(),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: displayList.asMap().entries.map((entry) {
                  return Container(
                    width: 6.0,
                    height: 6.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 3.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                  );
                }).toList(),
              ),
            ],
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

/*
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
          if (productList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'featured is currently unavailable.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          return CarouselSlider.builder(
            itemCount: productList.take(10).toList().length,
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
                            // ignore: deprecated_member_use
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
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(seconds: 1),
              autoPlayCurve: Curves.easeInOut,
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

*/
