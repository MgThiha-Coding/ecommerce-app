import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';

class BrandDetailPage extends ConsumerStatefulWidget {
  final int? brandId;
  const BrandDetailPage(this.brandId, {super.key});

  @override
  ConsumerState<BrandDetailPage> createState() => _BrandDetailPageState();
}

class _BrandDetailPageState extends ConsumerState<BrandDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(brandDetailNotifierProvider.notifier)
          .getBrandDetail(widget.brandId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandDetailAsync = ref.watch(brandDetailNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFC107),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Brand Details', style: GoogleFonts.poppins(fontSize: 14)),
      ),
      body: Container(
        child: brandDetailAsync.when(
          data: (brandDetail) {
            if (brandDetail?.data != null) {
              final brand = brandDetail!.data.name;
              final description =
                  brandDetail.data.description ?? "No description available";
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.orange.shade400,
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
                            Icons.storefront_outlined,
                            size: 50,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Brand Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand,
                            style: TextStyle(
                              fontSize: screenWidth * 0.065,
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

                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Since ${brandDetail.data.createdAt.toString()}",
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
          error: (err, _) => Center(child: Text(err.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
