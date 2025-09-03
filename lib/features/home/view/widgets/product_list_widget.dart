import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ProductListWidget extends ConsumerStatefulWidget {
  const ProductListWidget({super.key});

  @override
  ConsumerState<ProductListWidget> createState() => _BrandListWidgetState();
}

class _BrandListWidgetState extends ConsumerState<ProductListWidget> {
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final productListAsync = ref.watch(productNotifierProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: responsive.value(mobile: 200, tablet: 200, desktop: 210),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: productListAsync.when(
          data: (productListData) {
            final productList = productListData?.data?.data ?? [];

            if (productList.isEmpty) {
              return SizedBox.shrink();
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final productName = productList[index].name ?? "";
                final productImage = productList[index].productImage ?? "";
                return Card(
                  child: Container(
                    margin: EdgeInsets.all(3),

                    height: responsive.value(
                      mobile: 120,
                      tablet: 90,
                      desktop: 110,
                    ),

                    width: responsive.value(
                      mobile: 110,
                      tablet: 120,
                      desktop: 130,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: productImage.isEmpty
                                    ? SizedBox.shrink()
                                    : SizedBox.expand(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            productImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                              ),

                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: productName.isEmpty
                                      ? Text('No Product')
                                      : Text(
                                          productName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: GoogleFonts.poppins(
                                            fontSize: responsive.value(
                                              mobile: 9,
                                              tablet: 13,
                                              desktop: 15,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Product',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: responsive.value(
                                  mobile: 9,
                                  tablet: 10,
                                  desktop: 15,
                                ),
                                fontWeight: FontWeight.w400,
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
          error: (error, _) => const ProductListLoading(),
          loading: () => const ProductListLoading(),
        ),
      ),
    );
  }
}

class ProductListLoading extends StatelessWidget {
  const ProductListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          child: Container(
            margin: EdgeInsets.all(3),
            height: responsive.value(mobile: 90, tablet: 90, desktop: 110),
            width: responsive.value(mobile: 100, tablet: 120, desktop: 130),
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: Shimmer.fromColors(
                    baseColor: Colors.green.shade700,
                    highlightColor: Colors.green.shade400,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.value(
                            mobile: 5,
                            tablet: 10,
                            desktop: 15,
                          ),
                          fontWeight: FontWeight.w400,
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
  }
}
