import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/create_address/viewmodel/add_notifier.dart';
import 'package:picoshop_theme2/features/create_address/model/response/address_response.dart';

class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  int? selectedAddressId;
  AddressItem? selectedAddressData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressNotifierProvider.notifier).getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final addressesAsync = ref.watch(addressNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Select Address',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: responsive.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: addressesAsync.when(
        data: (addressResponse) {
          final data = addressResponse.data;

          if (!addressResponse.success || data.isEmpty) {
            return const Center(
              child: Text(
                'No saved addresses found.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final isSelected = selectedAddressId == item.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAddressId = item.id;
                    selectedAddressData = item;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade500,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.firstName} ${item.lastName}',
                              style: GoogleFonts.poppins(
                                fontSize: responsive.subHeading,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.addressLine1}, ${item.addressLine2}',
                              style: GoogleFonts.poppins(
                                fontSize: responsive.body,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.townshipEnName}, ${item.regionEnName}',
                              style: GoogleFonts.poppins(
                                fontSize: responsive.body,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  item.phone,
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.body,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.country}, ${item.postalZipCode}',
                              style: GoogleFonts.poppins(
                                fontSize: responsive.body,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: _buildShimmerList,
        error: (err, _) =>
            Center(child: Text(err.toString(), style: const TextStyle(color: Colors.redAccent))),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedAddressData == null
              ? null
              : () => Navigator.pop(context, selectedAddressData),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 120, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 14, width: double.infinity, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 14, width: 180, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 12, width: 100, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
