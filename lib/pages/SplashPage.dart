import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashFull();
  }
}

class SplashFull extends StatefulWidget {
  const SplashFull({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPage();
}

class _SplashPage extends State<SplashFull> {
  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Aplikasi Lapor Book',
            style: headerStyle(level: 1),),
          ),
        ));
  }

  void checkUserAuthentication() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user!=null) {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } catch (e) {
      print("Error during authentication check: $e");
    }
  }
}