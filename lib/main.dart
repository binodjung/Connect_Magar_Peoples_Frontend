import 'package:flutter/material.dart';
import 'features/authentication/login/presentation/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magar Community App',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Roboto'),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
