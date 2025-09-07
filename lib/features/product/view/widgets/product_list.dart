/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/view/widgets/loadings/product_loading.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

class ProductList extends ConsumerStatefulWidget {
  const ProductList({super.key});

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);
    final responsive = Responsive(context);
    return Flexible(
      fit: FlexFit.loose,
      child: productListAsync.when(
        data: (productListData) {
          final productList = productListData.data ?? [];
          if (productList.isEmpty) {
            return const Center(child: ProductLoading());
          }
          return GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: productList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.isMobile
                  ? 2
                  : responsive.isTablet
                  ? 5
                  : 6,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 110 / 130,
            ),
            itemBuilder: (context, index) {
              final productName = productList[index].name ?? "";
              final productImage = productList[index].productImage ?? "";
              final productId = productList[index].id;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(productId: productId),
                    ),
                  );
                },
                child: Card(
                  child: Container(
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
                                              mobile: 10,
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
                                  mobile: 10,
                                  tablet: 13,
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
                ),
              );
            },
          );
        },
        error: (error, _) => ProductLoading(),
        loading: () => ProductLoading(),
      ),
    );
  }
}


*/