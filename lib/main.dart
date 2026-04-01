import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/login/presentation/welcome_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final username = prefs.getString('user_username');
  final email = prefs.getString('user_email');

  runApp(MyApp(
    isLoggedIn: token != null,
    username: username,
    email: email,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;
  final String? email;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
    this.username,
    this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magar Community App',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Roboto'),
      home: isLoggedIn
          ? HomeScreen(
              username: username ?? 'User',
              email: email ?? '',
            )
          : const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
