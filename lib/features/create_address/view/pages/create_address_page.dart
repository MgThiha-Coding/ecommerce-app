import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/create_address/model/request/create_address_request.dart';
import 'package:picoshop_theme2/features/create_address/model/response/create_addresss_response.dart';
import 'package:picoshop_theme2/features/create_address/viewmodel/create_address_notifier.dart';

class CreateAddressPage extends ConsumerStatefulWidget {
  const CreateAddressPage({super.key});

  @override
  ConsumerState<CreateAddressPage> createState() => _CreateAddressPageState();
}

class _CreateAddressPageState extends ConsumerState<CreateAddressPage> {
  String _selectedType = "pickup";
  GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _regionIdController = TextEditingController();
  final TextEditingController _townshipIdController = TextEditingController();
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
    final createAddressAsync = ref.watch(createAddressNotifierProvider);
    ref.listen<AsyncValue<CreateAddressResponse?>>(
      createAddressNotifierProvider,
      (previous, next) {
        next.when(
          data: (data) {
            /*
            final addressId = data!.data?.id;
            if (data.success == true) {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShippingMethodPage(addressId!),
                ),
              );
              
            }*/
          },
          error: (error, _) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          },
          loading: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Loading...")));
          },
        );
      },
    );
    final responsive = Responsive(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade500,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CreateAddressAppBar(),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        width: double.infinity,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedType,
                              items: [
                                DropdownMenuItem(
                                  value: "pickup",
                                  child: Text(
                                    "Pickup",
                                    style: GoogleFonts.poppins(
                                      fontSize: responsive.body,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "delivery",
                                  child: Text(
                                    "Delivery",
                                    style: GoogleFonts.poppins(
                                      fontSize: responsive.body,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Select Address Type",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _firstNameController,

                              decoration: InputDecoration(
                                hintText: "First Name",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "First name is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                hintText: "Last Name",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressLine1Controller,
                              decoration: InputDecoration(
                                hintText: "Street / Road / Address",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Street / Road / Address is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressLine2Controller,
                              decoration: InputDecoration(
                                hintText: "Apartment / Floor / Block",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Apartment / Floor / Block is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _regionIdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Region ID",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Region ID is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _townshipIdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Township ID",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Township ID is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _postalCodeController,
                              decoration: InputDecoration(
                                hintText: "Postal / ZIP Code",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Postal / ZIP Code is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: "Phone Number",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 5,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Phone number is required";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: createAddressAsync.isLoading
                            ? null
                            : _submitAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: createAddressAsync.isLoading
                            ? SpinKitCircle(color: Colors.white, size: 27)
                            : Text(
                                "Save Address",
                                style: GoogleFonts.poppins(
                                  fontSize: responsive.body,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateAddressAppBar extends StatelessWidget {
  const CreateAddressAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 10),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            style: IconButton.styleFrom(
              // ignore: deprecated_member_use
              backgroundColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
            ),
          ),
          Text(
            'Address',
            style: GoogleFonts.poppins(
              fontSize: responsive.value(mobile: 15, tablet: 20, desktop: 25),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
