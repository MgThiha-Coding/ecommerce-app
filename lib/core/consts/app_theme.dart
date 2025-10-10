import 'package:flutter/widgets.dart';

class AppTheme {
  // Splash Page
  TextStyle splashTitle(BuildContext context) {
    return const TextStyle(
      fontSize: 30,
      color: Color.fromARGB(255, 73, 73, 75),
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle splashSubTitle(BuildContext context) {
    return const TextStyle(
      fontSize: 12,
      color: Color.fromARGB(255, 101, 100, 109),
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle body(BuildContext context) {
    return const TextStyle(
      fontSize: 10,
      color: Color.fromARGB(255, 253, 254, 255),
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle appTitle(BuildContext context) {
    return const TextStyle(
      fontSize: 24,
      color: Color.fromARGB(255, 253, 254, 255),
      fontWeight: FontWeight.bold,
    );
  }

  // Heading: light black
  TextStyle heading(BuildContext context) {
    return const TextStyle(
      fontSize: 19,
      color: Color.fromARGB(255, 34, 38, 41),
      fontWeight: FontWeight.bold,
    );
  }

  // Hint text: deep grey
  TextStyle hintText1(BuildContext context) {
    return const TextStyle(
      fontSize: 14,
      color: Color.fromARGB(255, 73, 72, 72),
      fontWeight: FontWeight.normal,
    );
  }
}
