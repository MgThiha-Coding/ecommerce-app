import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';
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
  String _selectedFilter = 'product';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (mounted) {
          ref.read(combinedProductSearchProvider.notifier).loadMore();
        }
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
      if (!mounted) return;
      final keyword = _searchController.text.trim();
      ref.read(combinedProductSearchProvider.notifier).search(
            keyword: keyword,
            filterType: _selectedFilter,
          );
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
        backgroundColor: Colors.white,
        title: Text(
          'Search',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by $_selectedFilter...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (_) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 6),
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
                            child: Text('Product', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'brand',
                            child: Text('Brand', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'category',
                            child: Text('Category', style: TextStyle(fontSize: 12))),
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
          Expanded(
            child: searchState.when(
              data: (results) {
                if (results.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    switch (_selectedFilter) {
                      case 'brand':
                        return _buildBrandTile(item);
                      case 'category':
                        return _buildCategoryTile(item);
                      default:
                        return _buildProductTile(item);
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(dynamic product) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
      title: Text(product.name ?? 'Unknown Product'),
      subtitle: Text(product.brandName ?? ''),
    );
  }

  Widget _buildBrandTile(BrandDataModel brand) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.business)),
      title: Text(brand.name),
      subtitle: Text('ID: ${brand.id}'),
    );
  }

  Widget _buildCategoryTile(CategoryDataModel category) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.category)),
      title: Text(category.name),
      subtitle: Text('ID: ${category.id}'),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 40, color: AppColors.textSecondary),
          SizedBox(height: 10),
          Text('No results found'),
        ],
      ),
    );
  }
}
