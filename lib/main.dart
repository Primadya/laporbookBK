import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/firebase_options.dart';
import 'package:lapor_book/pages/AddFormPage.dart';
import 'package:lapor_book/pages/dashboard/DahsboardPage.dart';
import 'package:lapor_book/pages/detail/AddCommentPage.dart';
import 'package:lapor_book/pages/detail/DetailPage.dart';
import 'package:lapor_book/pages/LoginPage.dart';
import 'package:lapor_book/pages/RegisterPage.dart';
import 'package:lapor_book/pages/SplashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "Lapor Book",
    initialRoute: "/",
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => const AddFormPage(),
      '/detail': (context) => const DetailPage(),
      '/add_comment': (context) => const AddCommentPage(),
    },
  ));
}