import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    //primary: Colors.green,
    surface: Colors.black,
    onSurface: Color.fromARGB(255, 40, 40, 40),
    secondary: Color.fromARGB(255, 239, 239, 243),
    onSecondary: Colors.white
  ),
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    //primary: Colors.green,
    surface: Color.fromARGB(255, 239, 239, 243),
    onSurface: Colors.white,
    secondary: Colors.black,
    onSecondary: Color.fromARGB(255, 40, 40, 40),
  ),
);
