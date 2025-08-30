import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final String? htmlDescription;

  const ProductDescriptionWidget({super.key, this.htmlDescription});

  @override
  Widget build(BuildContext context) {
    if (htmlDescription == null || htmlDescription!.isEmpty) {
      return const Text("No description available");
    }

    return Html(
      data: htmlDescription!,
      style: {
        "ul": Style(color: Colors.black),
        "li": Style(),
        "h4": Style(
          fontSize: FontSize.medium,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        "p": Style(),
      },
    );
  }
}
