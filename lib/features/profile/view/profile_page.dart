import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),

      body: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.amber.shade700,
            child: Center(
              child: Text(
                'Pico Shop',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                   ref.read(logOutNotifierProvider.notifier).logOut();
                },
                child: Text('Log Out', style: TextStyle(
                  color: Colors.white,
                  
                  
                  )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
