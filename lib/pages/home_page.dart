
import 'package:flutter/material.dart';
import 'package:phone_auth_firebase/controllers/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You are now logged in."),
            const SizedBox(height: 20),
            OutlinedButton(
                onPressed: () async {
                  await AuthService.logout();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: const Text("Logout"))
          ],
        ),
      ),
    );
  }
}
