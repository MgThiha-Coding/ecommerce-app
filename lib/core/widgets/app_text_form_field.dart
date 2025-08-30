import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/consts/app_theme.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool? addObscure;
  final String? Function(String?)? validator;

  const AppTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.addObscure = false, this.validator,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.addObscure ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();

    return TextFormField(
      obscureText: obscureText,
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: theme.hintText1(context),
        fillColor: Colors.grey.shade100,
        filled: true,
        suffixIcon: widget.addObscure == true
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20, 
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText; 
                  });
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2, color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2, color: Color(0xFF4A90E2)),
        ),

      
      ),

      validator: widget.validator
    );
  }
}
