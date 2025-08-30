import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/widgets/app_text_form_field.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback toggle;
  const RegisterPage({super.key, required this.toggle});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
    

  @override
  Widget build(BuildContext context) {
        double getHorizontalPadding(double width) {
      if (width >= 1400) return 400; 
      if (width >= 1024) return 200; 
      if (width >= 768) return 50; 
      return 15;
    }

    double screenWidth = MediaQuery.of(context).size.width;
  
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade300, Colors.grey.shade300],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration( 
                   gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:  
                   [
                      Colors.blue.shade900,
                      Colors.blue.shade500,
                      Colors.blue.shade100
                   ])
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPadding(screenWidth),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Pico Shop', style: GoogleFonts.poppins( 
                               fontSize: 24,
                               color: Colors.white,
                            )),
                            const SizedBox(width: 8.0),
                            Icon(
                              Icons.shopping_bag,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppTextFormField(
                          controller: _firstNameController,
                          hintText: "First Name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "First Name required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _lastNameController,
                          hintText: "Last Name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Last Name required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _emailController,
                          hintText: "Email",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _phoneController,
                          hintText: "Phone",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone number required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _passwordController,
                          hintText: "Password",
                          addObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _confirmController,
                          hintText: "Confirm Password",
                          addObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm Password required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          height: 46,
                          width: double.infinity,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {}
                            },
                            color: Colors.blue.shade900,
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4.0),
                            GestureDetector(
                              onTap: widget.toggle,
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
