import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/shipping/viewmodel/shipping_method_notifier.dart';

class ShippingMethodListPage extends ConsumerStatefulWidget {
  const ShippingMethodListPage({super.key});

  @override
  ConsumerState<ShippingMethodListPage> createState() => _ShippingMethodListPageState();
}

class _ShippingMethodListPageState extends ConsumerState<ShippingMethodListPage> {
  int? selectedMethodId;

  @override
  void initState() {
    super.initState();
    ref.read(shippingMethodNotifierProvider.notifier).getShippingMethod();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final shippingState = ref.watch(shippingMethodNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Shipping Method',
          style: TextStyle(fontSize: responsive.heading, color: Colors.black),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: shippingState.when(
        data: (data) {
          final methods = data?.data ?? [];
          if (methods.isEmpty) {
            return const Center(child: Text('No shipping methods available'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: methods.length,
                  itemBuilder: (context, index) {
                    final method = methods[index];
                    final isSelected = selectedMethodId == method.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethodId = method.id;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.primary : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                method.name,
                                style: TextStyle(
                                  fontSize: responsive.subHeading,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: selectedMethodId == null
                      ? null
                      : () {
                          // Navigate to payment page with selectedMethodId
                          Navigator.pushNamed(context, '/payment', arguments: selectedMethodId);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: responsive.subHeading, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}
