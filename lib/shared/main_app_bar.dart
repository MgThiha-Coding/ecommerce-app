import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class AppMainBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color iconThemeColor;

  const AppMainBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions, 
    this.backgroundColor = Colors.white,  this.iconThemeColor = Colors.black,
  });

  @override 
  Widget build(BuildContext context) {
    final fontSize = Responsive(context);
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title,
        style:  TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: fontSize.heading,
        ),
      ),
      actions: actions,
      centerTitle: true,
      iconTheme: IconThemeData(color: iconThemeColor),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
