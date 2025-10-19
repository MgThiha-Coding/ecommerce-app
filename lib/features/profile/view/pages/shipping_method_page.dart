import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/shipping/viewmodel/shipping_method_notifier.dart';


class ShippingMethodPage extends ConsumerStatefulWidget {
  const ShippingMethodPage({super.key});

  @override
  ConsumerState<ShippingMethodPage> createState() => _ShippingMethodPageState();
}

class _ShippingMethodPageState extends ConsumerState<ShippingMethodPage> {
  int? selectedMethodId;
  ShippingMethod? selectedMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shippingMethodNotifierProvider.notifier).getShippingMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final shippingAsync = ref.watch(shippingMethodNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shipping Methods",
          style: TextStyle(fontSize: responsive.subHeading, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
      ),
      body: shippingAsync.when(
        data: (response) {
          if (response == null || response.data.isEmpty) {
            return const Center(child: Text("No shipping methods available"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final method = response.data[index];
              final isSelected = selectedMethodId == method.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethodId = method.id;
                    selectedMethod = method;
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : Colors.grey.shade500,
                    ),
                    title: Text(
                      method.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w400,fontSize: Responsive(context).body),
                    ),
                    subtitle: Text(method.amount),
                  ),
                ),
              );
            },
          );
        },
        loading: () => _buildShimmerList(),
        error: (err, _) => Center(child: Text(err.toString(), style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 60,
          ),
        );
      },
    );
  }
}
