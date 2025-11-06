import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/create_address/model/create_address_request.dart';
import 'package:picoshop_theme2/features/create_address/model/create_addresss_response.dart';
import 'package:picoshop_theme2/features/create_address/viewmodel/create_address_notifier.dart';
import 'package:picoshop_theme2/features/location/model/local_region_response.dart';
import 'package:picoshop_theme2/features/location/view/available_township_page.dart';
import 'package:picoshop_theme2/features/location/viewmodel/local_region_notifier.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:picoshop_theme2/shared/app_text_field.dart';

class CreateAddressPage extends ConsumerStatefulWidget {
  const CreateAddressPage({super.key});

  @override
  ConsumerState<CreateAddressPage> createState() => _CreateAddressPageState();
}

class _CreateAddressPageState extends ConsumerState<CreateAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'pickup';
  RegionItem? _selectedRegion;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _regionIdController = TextEditingController();
  final TextEditingController _townshipIdController = TextEditingController();
  final TextEditingController _townshipNameController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _regionIdController.dispose();
    _townshipIdController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(createAddressNotifierProvider.notifier)
          .createAddress(
            CreateAddressRequest(
              type: _selectedType,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              addressLine1: _addressLine1Controller.text,
              addressLine2: _addressLine2Controller.text,
              regionId: int.tryParse(_regionIdController.text) ?? 0,
              townshipId: int.tryParse(_townshipIdController.text) ?? 0,
              postalZipCode: _postalCodeController.text,
              phone: _phoneController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final createAddressAsync = ref.watch(createAddressNotifierProvider);
    final regionState = ref.watch(localRegionNotifierProvider);

    ref.listen<AsyncValue<CreateAddressResponse?>>(
      createAddressNotifierProvider,
      (prev, next) {
        next.when(
          data: (data) {
            if (data != null && data.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Address saved successfully',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors.textSecondary,
                      fontSize: Responsive(context).body,
                    ),
                  ),
                  backgroundColor: AppColors.background,
                  duration: const Duration(milliseconds: 20000),
                ),
              );
              Navigator.pop(context);
            }
          },
          loading: () {},
          error: (err, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  err.toString(),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColors.error,
                    fontSize: Responsive(context).body,
                  ),
                ),
                backgroundColor: AppColors.background,
                duration: const Duration(milliseconds: 20000),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,

        title: Text(
          "Shipping Address",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: responsive.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Type
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
                  DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                ],
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: InputDecoration(
                  hintText: 'Select Address Type',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  fontSize: responsive.subHeading,
                  color: AppColors.textSecondary,
                ),
                isDense: true,
              ),
              const SizedBox(height: 16),

              // Personal Details
              Text(
                "Personal Details",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _firstNameController,
                labelText: "First Name",
                hintText: 'Enter your first name',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter first name'
                    : null,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _lastNameController,
                labelText: "Last Name",
                hintText: 'Enter your last name',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter last name'
                    : null,
              ),
              const SizedBox(height: 16),

              // Address Details
              Text(
                'Address Details',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),
              AppTextField(
                controller: _addressLine1Controller,
                labelText: 'Street Address',
                hintText: 'e.g., 123 Main St',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter your address 1'
                    : null,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _addressLine2Controller,
                labelText: 'Apartment, Floor, or Block',
                hintText: 'Optional',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter your address 2'
                    : null,
              ),
              const SizedBox(height: 10),

              // Location Details
              Text(
                'Location Details',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: regionState.when(
                        data: (regions) {
                          return DropdownButtonFormField<RegionItem>(
                            initialValue: _selectedRegion,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            focusColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: 'Select Region',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: regions.map((region) {
                              return DropdownMenuItem<RegionItem>(
                                value: region,
                                child: Text(
                                  region.enName ?? region.mmName ?? '-',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (region) async {
                              if (region == null) return;
                              setState(() {
                                _selectedRegion = region;
                                _regionIdController.text = region.id.toString();
                              });

                              final selectedTownship = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AvailableTownshipPage(region.id),
                                ),
                              );

                              if (selectedTownship != null) {
                                setState(() {
                                  _townshipIdController.text = selectedTownship
                                      .id
                                      .toString();
                                  _townshipNameController.text =
                                      selectedTownship.enName;
                                });
                              }
                            },
                          );
                        },
                        loading: () => const Center(child: Text('Loading....')),
                        error: (err, _) => Text('Error: $err'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: AppTextField(
                      labelText: 'Township',
                      controller: _townshipNameController,
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Please enter township'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: AppTextField(
                      controller: _townshipIdController,
                      labelText: 'ID',
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'ID' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _postalCodeController,
                labelText: 'Postal / ZIP Code',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter postal code'
                    : null,
              ),
              const SizedBox(height: 10),

              // Contact Info
              Text(
                'Contact Information',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.number,
                hintText: 'Phone Number',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter phone number'
                    : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: AppButton(
                  title: "Save Address",
                  onTap: () {
                    _submitAddress();
                  },
                  isLoading: createAddressAsync.isLoading,
                  backgroundColor: AppColors.primary,
                  labelColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
