import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_detail_page.dart';
import 'package:picoshop_theme2/features/search/viewmodel/product_search_notifier.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  final String _selectedFilter = 'product';

  @override
  void initState() {
    super.initState();

    // Infinite scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(productSearchNotifierProvider.notifier).loadMore();
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
      if (keyword.isEmpty) {
        ref.read(productSearchNotifierProvider.notifier).resetSearch();
        return;
      }

      final notifier = ref.read(productSearchNotifierProvider.notifier);

      switch (_selectedFilter) {
        case 'brand':
          notifier.search(brand: keyword);
          break;
        case 'category':
          notifier.search(category: keyword);
          break;
        default:
          notifier.search(name: keyword);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productSearchNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        title: Text(
          'Search Products',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  e.toString(),
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: 'Search by $_selectedFilter...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            /*
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
                      child: Text('Product', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'brand',
                      child: Text('Brand', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 'category',
                      child: Text('Category', style: TextStyle(fontSize: 12)),
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
            */
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
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppImage.emptyContainer,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
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
        trailing: Text(
          product.stockSumCurrentQuantity ?? '',
          style: GoogleFonts.poppins(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(
            'No products found',
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
