import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings'),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Enable Location Services'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}