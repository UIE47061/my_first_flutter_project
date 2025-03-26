import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/pages/login_page.dart';
// import 'package:my_first_flutter_project/pages/sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

