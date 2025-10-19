import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/shipping/viewmodel/shipping_method_notifier.dart';

class ShippingMethodPage extends ConsumerStatefulWidget {
  const ShippingMethodPage({super.key});

  @override
  ConsumerState<ShippingMethodPage> createState() => _ShippingMethodPageState();
}

class _ShippingMethodPageState extends ConsumerState<ShippingMethodPage> {
  String? _selectedShippingId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(shippingMethodNotifierProvider.notifier).getShippingMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final shippingMethodAsync = ref.watch(shippingMethodNotifierProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Select Shipping Method',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: responsive.subHeading,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: shippingMethodAsync.when(
          data: (data) {
            if (data == null || data.data.isEmpty)
              return const Center(child: Text('No shipping methods available'));
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: data.data.length,
                    itemBuilder: (context, index) {
                      final method = data.data[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: RadioListTile<String>(
                          value: method.id.toString(),
                          groupValue: _selectedShippingId,
                          onChanged: (value) {
                            setState(() {
                              _selectedShippingId = value;
                            });
                          },
                          title: Text(
                            method.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: responsive.body,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.amount,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: responsive.body,
                                ),
                              ),
                              Text(
                                method.descriptions,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: responsive.body - 1,
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
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: _selectedShippingId != null ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: responsive.body,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text(err.toString())),
        ),
      ),
    );
  }
}
