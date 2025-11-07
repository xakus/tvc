import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TVApp());
}

class TVApp extends StatelessWidget {
  const TVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomePage(),
    );
  }
}
