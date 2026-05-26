import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CompanyEmailScraperApp());
}

class CompanyEmailScraperApp extends StatelessWidget {
  const CompanyEmailScraperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company Email Scraper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
