import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/search/viewmodel/product_search_notifier.dart';
import 'package:picoshop_theme2/shared/app_text_field.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  String _selectedFilter = 'product';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(combinedProductSearchProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final keyword = _searchController.text.trim();
      final notifier = ref.read(combinedProductSearchProvider.notifier);

      if (keyword.isEmpty) {
        notifier.reset();
        return;
      }

      notifier.search(keyword: keyword, filterType: _selectedFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(combinedProductSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        title: Text(
          LocaleKeys.searchProduct.tr(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue.withOpacity(0.3)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _searchController,
                        hintText: 'Search by $_selectedFilter...',
                        validator: (_) => null,
                        addObscure: false,
                        onChanged: (_) => _onSearchChanged(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          items: const [
                            DropdownMenuItem(
                              value: 'product',
                              child: Text(
                                'Product',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'brand',
                              child: Text(
                                'Brand',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'category',
                              child: Text(
                                'Category',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedFilter = value);
                              _onSearchChanged();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: searchState.when(
                data: (products) {
                  if (products.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductTile(product);
                    },
                  );
                },
                loading: () => const _AnimatedSearchingText(),
                error: (e, _) => Center(
                  child: Text(
                    'Something went wrong',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(ProductDataModel product) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product.id!),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          radius: 25,
          child: ClipOval(
            child: product.image != null && product.image!.isNotEmpty
                ? Image.network(
                    product.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AppImage.emptyContainer,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    AppImage.emptyContainer,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          product.name ?? 'Unknown Product',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: Responsive(context).body,
          ),
        ),
        subtitle: Text(
          product.brandName ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            'No products found',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSearchingText extends StatefulWidget {
  const _AnimatedSearchingText({Key? key}) : super(key: key);

  @override
  State<_AnimatedSearchingText> createState() => _AnimatedSearchingTextState();
}

class _AnimatedSearchingTextState extends State<_AnimatedSearchingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDots(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        int activeDot = (_animation.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedOpacity(
                opacity: i <= activeDot ? 1 : 0.2,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '.',
                  style: TextStyle(
                    color: color,
                    fontSize: Responsive(context).body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const color = AppColors.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Searching',
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w500,
            fontSize: Responsive(context).subHeading,
          ),
        ),
        _buildAnimatedDots(color),
      ],
    );
  }
}
