import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';

class CategoryDetailPage extends ConsumerStatefulWidget {
  final int? categoryId;
  const CategoryDetailPage(this.categoryId, {super.key});

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      //ref.read(categoryDetailNotifierProvider.notifier).getCagetoryDetail(widget.categoryId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetailAsync = ref.watch(categoryDetailNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Category Detail',style: GoogleFonts.poppins( 
           fontSize: 14,
        ),),
        centerTitle: true,
        backgroundColor: Color(0xFFFFC107),
        scrolledUnderElevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFC107), Color(0xFFFFE082), Color(0xFFA5D6A7)],
          ),
        ),
        child: categoryDetailAsync.when(
          data: (categoryDetail) {
            if (categoryDetail?.data != null) {
              final categoryName = categoryDetail!.data.name;
              final description =
                  categoryDetail.data.description ?? "No description available";

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header / decorative banner
                    Container(
                      height: screenHeight * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.category_outlined,
                            size: 50,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Optional: Created at info
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Created: ${categoryDetail.data.createdAt.toString()}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          error: (err, _) => Center(child: Text('')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
