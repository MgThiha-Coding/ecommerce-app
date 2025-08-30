import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/category/view/category_detail_page.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';

class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({super.key});

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoriesListNotifierProvider.notifier).getCagetoryList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF212121)),
        title: const Text(
          'Categories',
          style: TextStyle(color: Color(0xFF212121), fontSize: 17),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: categoriesAsync.when(
          data: (categoryData) {
            if (categoryData != null && categoryData.data.data.isNotEmpty) {
              return ListView.builder(
                itemCount: categoryData.data.data.length,
                itemBuilder: (context, index) {
                  final category = categoryData.data.data[index].name;
                  final description = categoryData.data.data[index].description ?? "";
                  final categoryId = categoryData.data.data[index].id;

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.category_outlined,
                        color: Colors.green,
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      subtitle: Text(description),
                      trailing: IconButton(
                        onPressed: () {
                        
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(categoryId)
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: SizedBox.shrink());
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(
            child: Text('Failed to load categories. Please try again.'),
          ),
        ),
      ),
    );
  }
}
