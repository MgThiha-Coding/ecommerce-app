import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/service/pagination_provider.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/view/widgets/loadings/product_loading.dart';
import 'package:picoshop_theme2/features/product/view/widgets/search_appbar.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ProductSearchPage extends ConsumerStatefulWidget {
  final String initialQuery;
  const ProductSearchPage({super.key, required this.initialQuery});

  @override
  ConsumerState<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends ConsumerState<ProductSearchPage> {
  final ScrollController _scrollController = ScrollController();
  final double itemHeight = 130.0;
  final int itemsBeforeButton = 15;
  late final double offsetToShowButton = ((itemsBeforeButton / 2).ceil()) * itemHeight;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
    getFirstProductList();
    _scrollController.addListener(() {
      if (_scrollController.offset >= offsetToShowButton && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset < offsetToShowButton && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  Future<void> getProductList() async {
    Future.microtask(() {
      final noMore = ref.watch(isNoMoreProvider);
      if (noMore) return;
      final state = ref.watch(productNotifierProvider);
      if (!state.isLoading) {
        ref.read(productNotifierProvider.notifier).getProductList(ref.watch(pageProvider));
      }
    });
  }

  Future<void> getFirstProductList() async {
    Future.microtask(() {
      ref.read(productListProvider.notifier).state = [];
      ref.read(pageProvider.notifier).state = 0;
      ref.read(isNoMoreProvider.notifier).state = false;
      ref.read(productNotifierProvider.notifier).getProductList(ref.watch(pageProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);
    final productList = ref.watch(productListProvider);
    final noMore = ref.watch(isNoMoreProvider);

    final query = ref.watch(searchQueryProvider);
    final filteredList = query.isEmpty
        ? productList
        : productList.where((p) => p?.name?.toLowerCase().contains(query.toLowerCase()) ?? false).toList();

    ref.listen(productNotifierProvider, (prev, next) {
      next.when(
        data: (data) {
          ref.read(pageProvider.notifier).update((state) => state + 1);
          ref.read(productListProvider.notifier).update((state) => [...state, ...data]);
          ref.read(isNoMoreProvider.notifier).state = data.isEmpty ? true : false;
        },
        error: (_, __) {},
        loading: () {},
      );
    });

    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade900, Colors.blue.shade500, Colors.blue.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                CustomMaterialIndicator(
                  onRefresh: getProductList,
                  backgroundColor: Colors.white,
                  indicatorBuilder: (context, controller) {
                    return SpinKitFadingCircle(color: Colors.blue, size: 35.0);
                  },
                  child: Column(
                    children: [
                      SearchAppbar(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TextField(
                      
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).state = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric( 
                              vertical: 8,
                              horizontal: 8
                            )
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredList.isEmpty
                            ? ProductLoading()
                            : productListView(state, noMore, filteredList, _scrollController),
                      ),
                    ],
                  ),
                ),
                if (_showScrollToTop)
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: AnimatedOpacity(
                      opacity: _showScrollToTop ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () {
                          _scrollController.animateTo(
                            0.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.6), shape: BoxShape.circle),
                          child: Icon(Icons.arrow_upward, color: Colors.white),
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

GridView productListView(
    AsyncValue<List<ChildData?>> state, bool noMore, List<ChildData?> productList, ScrollController _scrollController) {
  return GridView.builder(
    controller: _scrollController,
    itemCount: (state.isLoading || noMore) ? productList.length + 1 : productList.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 110 / 130,
    ),
    itemBuilder: (context, index) {
      final productData = productList[index];
      final productId = productList[index]?.id;
      if (index < productList.length) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailPage(productId: productId)),
            );
          },
          child: productCard(context, productData!),
        );
      } else {
        return noMore ? Center(child: Text('No More Products')) : SpinKitCircle(size: 24, color: Colors.white);
      }
    },
  );
}

Widget productCard(BuildContext context, ChildData data) {
  final productImage = data.productImage ?? '';
  final productName = data.name ?? '';
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: productImage.isEmpty
                ? SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      child: Image.asset(AppImage.emptyContainer, fit: BoxFit.cover),
                    ),
                  )
                : SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      child: Image.network(
                        productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ClipRRect(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          child: Image.asset(AppImage.emptyContainer, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(productName, overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          ),
        ],
      ),
    ),
  );
}
