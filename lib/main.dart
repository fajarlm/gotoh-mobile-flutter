import 'package:fe_mobile/views/on_board.dart';
import 'package:fe_mobile/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoToh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: fromCssColor('#FF5733')),
      ),
      home:SplashScreen(),
    );
  }
}