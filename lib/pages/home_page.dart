import 'package:flutter/material.dart';
import '../controllers/auth_service.dart';

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
            const Text("You are logged in!"),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                await AuthService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SizedBox.shrink()),
                      (_) => false,
                );
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
