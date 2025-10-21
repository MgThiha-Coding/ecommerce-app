import 'package:flutter/material.dart';


class AppTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool addObscure;
  final String? Function(String?)? validator;

  const AppTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.addObscure = false,
    this.validator,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.addObscure;
  }

  @override
  Widget build(BuildContext context) {
   

    return TextFormField(
      controller: widget.controller,
      obscureText: obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        suffixIcon: widget.addObscure
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 2,
            color: Color(0xFFFFC107) , 
          ),
        ),
      ),
    );
  }
}
