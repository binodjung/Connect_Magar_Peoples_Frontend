import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/login/presentation/welcome_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'core/utils/toast_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final username = prefs.getString('user_username');
  final email = prefs.getString('user_email');

  runApp(
    MyApp(
      isLoggedIn: token != null,
      username: username,
      email: email,
    ),
  );
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
      scaffoldMessengerKey: ToastUtil.messengerKey,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFF8B0000),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF8B0000),
          elevation: 0,
        ),
      ),
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
