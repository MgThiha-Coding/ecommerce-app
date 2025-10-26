import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/address/model/request/create_address_request.dart';
import 'package:picoshop_theme2/features/address/model/response/create_addresss_response.dart';
import 'package:picoshop_theme2/features/address/viewmodel/create_address_notifier.dart';
import 'package:picoshop_theme2/features/location/model/local_region_response.dart';
import 'package:picoshop_theme2/features/location/view/available_township_page.dart';
import 'package:picoshop_theme2/features/location/view/current_location_page.dart';
import 'package:picoshop_theme2/features/location/viewmodel/local_region_notifier.dart';
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

  LatLng? _selectedLocation;
  String _detectedAddress = '';

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

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CurrentLocationPage()),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
      });
      await _detectZipCodeWithGeocodingPackage(result);
    }
  }

  Future<void> _detectZipCodeWithGeocodingPackage(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _detectedAddress =
              '${place.street}, ${place.locality}, ${place.administrativeArea}';
          _postalCodeController.text = place.postalCode!;
          _addressLine1Controller.text = place.street!;
          _addressLine2Controller.text = place.locality!;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address detection failed: ${e.toString()}')),
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
                const SnackBar(content: Text('Address saved successfully')),
              );
              Navigator.pop(context);
            }
          },
          loading: () {},
          error: (err, _) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(err.toString())));
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Shipping Address',
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
                'Personal Details',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                hintText: 'Enter your first name',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'First Name is required'
                    : null,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Last Name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Address Details
              Text(
                'Address Details',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),
              AppTextField(
                controller: _addressLine1Controller,
                labelText: 'Street Address',
                hintText: 'e.g., 123 Main St',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter your address'
                    : null,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _addressLine2Controller,
                labelText: 'Apartment, Floor, or Block',
                hintText: 'Optional',
              ),
              const SizedBox(height: 10),
              /*
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.map, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'Location on Map',
                                style: TextStyle(
                                  fontSize: responsive.body,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedLocation == null
                                ? 'Tap to select your exact location on map'
                                : 'Location selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: responsive.body,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_detectedAddress.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Detected Address:',
                              style: TextStyle(
                                fontSize: responsive.body,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _detectedAddress,
                              style: TextStyle(
                                fontSize: responsive.body,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickLocationOnMap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(120, 40),
                            ),
                            child: Text(
                              'Select on Map',
                              style: TextStyle(
                                fontSize: responsive.body,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _addressLine1Controller,
                      labelText: 'Street Address',
                      hintText: 'e.g., 123 Main St',
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Please enter your address'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _addressLine2Controller,
                      labelText: 'Apartment, Floor, or Block',
                      hintText: 'Optional',
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              */
              const SizedBox(height: 16),

              // Location Details
              Text(
                'Location Details',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: responsive.subHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: regionState.when(
                        data: (regions) {
                          return DropdownButtonFormField<RegionItem>(
                            value: _selectedRegion,
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
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error: $err'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: AppTextField(
                      labelText: 'Township Name',
                      controller: _townshipNameController,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: AppTextField(
                      controller: _townshipIdController,
                      labelText: 'ID',
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Township ID is required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _postalCodeController,
                labelText: 'Postal / ZIP Code',
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
                hintText: 'Enter your phone number',
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Phone is required' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: createAddressAsync.isLoading ? null : _submitAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: createAddressAsync.isLoading
                    ? const SpinKitCircle(color: Colors.white, size: 27)
                    : Text(
                        'Save Address',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: responsive.body,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
