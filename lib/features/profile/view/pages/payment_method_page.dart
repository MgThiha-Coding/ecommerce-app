import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/payment/viewmodel/payment_notifier.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  int? selectedPaymentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentMethodNotifierProvider.notifier).getPaymentMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final paymentAsync = ref.watch(paymentMethodNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment Methods",
          style: TextStyle(
            fontSize: responsive.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
      ),
      body: paymentAsync.when(
        data: (response) {
          if (response == null || response.data.isEmpty) {
            return const Center(child: Text("No payment methods available"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final method = response.data[index];
              final isSelected = selectedPaymentId == method.id;

              return GestureDetector(
                onTap: () => setState(() => selectedPaymentId = method.id),
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
                    subtitle: method.paymentAccount?.accountNumber != null
                        ? Text(method.paymentAccount!.accountNumber!)
                        : null,
                  ),
                ),
              );
            },
          );
        },
        loading: () => _buildShimmerList(),
        error: (err, _) => Center(
          child: Text(
            err.toString(),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
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
