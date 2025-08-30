import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/brands/view/brand_detail_page.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';

class BrandListPage extends ConsumerStatefulWidget {
  const BrandListPage({super.key});

  @override
  ConsumerState<BrandListPage> createState() => _BrandListPageState();
}

class _BrandListPageState extends ConsumerState<BrandListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(brandListNotifierProvider.notifier).getBrandList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandListAsync = ref.watch(brandListNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF212121)),

        title: Text(
          'Brands',
          style: TextStyle(color: Color(0xFF212121), fontSize: 17),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: brandListAsync.when(
          data: (brandData) {
            if (brandData != null && brandData.data.data.isNotEmpty) {
              return ListView.builder(
                itemCount: brandData.data.data.length,
                itemBuilder: (context, index) {
                  final brand = brandData.data.data[index].name;
                  final description =
                      brandData.data.data[index].description ?? "";
                  final brandId = brandData.data.data[index].id;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.storefront_outlined,
                        color: Colors.green,
                      ),
                      title: Text(
                        brand,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      subtitle: Text(description),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BrandDetailPage(brandId),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward_ios),
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
            child: Text('Failed to load brands. Please try again.'),
          ),
        ),
      ),
    );
  }
}
