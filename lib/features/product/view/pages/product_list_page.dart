import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/home/widgets/home_app_bar.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
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
  bool _emptyToastShown = false;
  bool _errorToastShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).getNextPage();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(productNotifierProvider.notifier).getNextPage();
      }
    });
  }

  Future<void> _onRefresh() async {
    _emptyToastShown = false;
    _errorToastShown = false;
    await ref.read(productNotifierProvider.notifier).reset();
  }

  void _showToast(
    String message, {
    ToastificationType type = ToastificationType.info,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Icon? icon;
      Color color;
      switch (type) {
        case ToastificationType.success:
          icon = const Icon(Icons.check_circle_outline, color: Colors.green);
          color = Colors.greenAccent.shade100;
          break;
        case ToastificationType.error:
          icon = const Icon(Icons.error_outline, color: Colors.red);
          color = Colors.redAccent.shade100;
          break;
        case ToastificationType.info:
        default:
          icon = const Icon(Icons.info_outline, color: Colors.blue);
          color = Colors.blue.shade100;
      }
      toastification.show(
        title: Text(message),
        icon: icon,
        showIcon: true,
        backgroundColor: color,
        autoCloseDuration: const Duration(seconds: 3),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);

    return Container(
      color: Colors.blue.shade500,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 3),
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
                    onRefresh: _onRefresh,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: productListAsync.when(
                          loading: () => productGridShimmer(context),
                          error: (e, _) {
                            if (!_errorToastShown) {
                              _errorToastShown = true;
                              _showToast(
                                e.toString(),
                                type: ToastificationType.error,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          data: (products) {
                            if (products.isEmpty) {
                              if (!_emptyToastShown) {
                                _emptyToastShown = true;
                                _showToast(
                                  'No products available',
                                  type: ToastificationType.info,
                                );
                              }
                              return Center(
                                child: Text(
                                  'No products available.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            return GridView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: products.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: Responsive(context).isMobile
                                        ? 3
                                        : 5,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1 / 1.2,
                                  ),
                              itemBuilder: (context, index) {
                                final productName = products[index].name ?? '';
                                final productImage =
                                    products[index].productImage ?? '';
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailPage(),
                                      ),
                                    );
                                  },
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
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    topRight: Radius.circular(
                                                      7,
                                                    ),
                                                  ),
                                              child: productImage.isEmpty
                                                  ? Image.asset(
                                                      AppImage.emptyContainer,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      productImage,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => SizedBox.expand(
                                                            child: Image.asset(
                                                              AppImage
                                                                  .emptyContainer,
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
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

GridView productGridShimmer(BuildContext context, {int itemCount = 15}) {
  final responsive = Responsive(context);
  return GridView.builder(
    itemCount: itemCount,
    physics: const AlwaysScrollableScrollPhysics(),
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
