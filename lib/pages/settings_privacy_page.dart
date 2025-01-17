import 'package:flutter/material.dart';

class SettingsPrivacyPage extends StatelessWidget {
  const SettingsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text("Settings & Privacy"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          _buildSettingItem("Account Settings", Icons.account_circle),
          _buildSettingItem("Privacy Settings", Icons.lock),
          _buildSettingItem("Notification Preferences", Icons.notifications),
          _buildSettingItem("Language", Icons.language),
          _buildSettingItem("About", Icons.info),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[600]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Placeholder for future functionality
      },
    );
  }
}
