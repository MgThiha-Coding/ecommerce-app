import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:picoshop_theme2/features/brands/view/pages/brand_list_page.dart';
import 'package:picoshop_theme2/features/category/view/pages/category_list_page.dart';
import 'package:picoshop_theme2/features/order_history/view/order_history_list_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/product/viewmodel/product_notifier.dart';
import 'package:picoshop_theme2/features/search/view/pages/search_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController scrollController = ScrollController();
  bool _isFetchingProducts = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getNextPageAll();
    });
   
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        _getNextPageAll();
      }
    });
  }

  Future<void> _resetAll() async {
    await Future.wait([
      ref.read(brandListNotifierProvider.notifier).reset(),
      ref.read(categoryListNotifierProvider.notifier).reset(),
      ref.read(productNotifierProvider.notifier).reset(),
    ]);
    _getNextPageAll();
  }

  void _getNextPageAll() async {
    if (_isFetchingProducts) return;
    _isFetchingProducts = true;
    try {
      await Future.wait([
        ref.read(brandListNotifierProvider.notifier).getNextPage(),
        ref.read(categoryListNotifierProvider.notifier).getNextPage(),
        ref.read(productNotifierProvider.notifier).getNextPage(),
      ]);
    } finally {
      _isFetchingProducts = false;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 30,
            color: AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: Responsive(context).body,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer({required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: AppColors.background,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productNotifierProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          // ignore: deprecated_member_use
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Consumer(
            builder: (context, ref, _) {
              return Row(
                children: [
                  /*
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CircleAvatar(child: Image.asset(AppImage.appLogo)),
                  ),
                  */
                  
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${LocaleKeys.welcome.tr()} ',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: Responsive(context).body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Icon(
                              Icons.waving_hand,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                        Text(
                          ref.watch(userProvider)?.name ?? "Guest",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: Responsive(context).subHeading,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SearchBar()),
                  
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryListPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        LineIcons.shoppingBag,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  
                ],
              );
            },
          ),
          bottom: TabBar(
            // isScrollable: true,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.textSecondary,
            labelPadding: const EdgeInsets.symmetric(horizontal: 3),
            labelStyle: TextStyle(
              fontFamily: "Poppins",
              fontSize: Responsive(context).body,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Products"),
              Tab(text: "Brands"),
              Tab(text: "Categories"),
              Tab(text: "New"),
            ],
          ),
        ),

        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _resetAll,
            child: TabBarView(
              children: [
                //const ProductListPage(),
                ProductGridSection(
                  productListAsync: productListAsync,
                  buildEmptyState: _buildEmptyState,
                  buildShimmer: ({double height = 200}) =>
                      _buildShimmer(height: height),
                  scrollController: scrollController,
                ),

                const BrandListPage(),
                const CategoryListPage(),
                Center(
                  child: Text(
                    'New Arrivals\n(Coming Soon)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive(context).body,
                      color: Colors.blue,
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

// SearchBar Widget
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: SizedBox(
          height: 43,
          child: AbsorbPointer(
            child: TextField(
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: fontSize.caption,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: LocaleKeys.search.tr(),
                hintStyle: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: fontSize.body,
                  color: AppColors.textPrimary,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LineIcons.search,
                    color: Colors.white,
                    size: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Product Grid Section
class ProductGridSection extends ConsumerWidget {
  final AsyncValue<List<ProductDataModel>> productListAsync;
  final Widget Function(String message) buildEmptyState;
  final Widget Function({double height}) buildShimmer;
  final ScrollController scrollController;

  const ProductGridSection({
    Key? key,
    required this.productListAsync,
    required this.buildEmptyState,
    required this.buildShimmer,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: productListAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return buildEmptyState('Product list is currently unavailable.');
          }

          final previewList = list.toList();

          return RefreshIndicator(
            color: AppColors.textSecondary,
            backgroundColor: AppColors.background,
            onRefresh: () async {
              await ref.read(productNotifierProvider.notifier).reset();
            },
            child: GridView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive(context).isMobile ? 2 : 5,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.68,
              ),
              itemCount: previewList.length,
              itemBuilder: (context, index) {
                final product = previewList[index];
                final productId = product.id;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(productId!),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
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
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: Image.network(
                            product.productImage ?? AppImage.emptyContainer,
                            fit: BoxFit.cover,
                            height: 160,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Image.asset(
                              AppImage.emptyContainer,
                              fit: BoxFit.cover,
                              height: 160,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.productType ?? "",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.priceLabelColor,
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
        loading: () => buildShimmer(height: 200),
        error: (err, _) => buildEmptyState(err.toString()),
      ),
    );
  }
}
