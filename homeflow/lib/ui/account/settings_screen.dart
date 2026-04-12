import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Variables locales para simular que los ajustes cambian
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _darkMode = false;
  bool _biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EDFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF203DA3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF203DA3), fontWeight: FontWeight.w800, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSectionTitle('Notifications'),
            _buildSettingsCard([
              _buildSwitchRow('Push Notifications', Icons.notifications_active_outlined, _pushNotifications, (val) => setState(() => _pushNotifications = val)),
              _buildDivider(),
              _buildSwitchRow('Email Alerts', Icons.email_outlined, _emailAlerts, (val) => setState(() => _emailAlerts = val)),
            ]),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('Preferences'),
            _buildSettingsCard([
              _buildSwitchRow('Dark Mode', Icons.dark_mode_outlined, _darkMode, (val) {
                setState(() => _darkMode = val);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dark mode is coming soon!')));
                Future.delayed(const Duration(milliseconds: 500), () => setState(() => _darkMode = false));
              }),
            ]),

            const SizedBox(height: 32),

            _buildSectionTitle('Security'),
            _buildSettingsCard([
              _buildSwitchRow('Face ID / Touch ID', Icons.fingerprint, _biometricLogin, (val) => setState(() => _biometricLogin = val)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(String title, IconData icon, bool currentValue, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: const Color(0xFF203DA3), size: 22),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            ],
          ),
          Switch(
            value: currentValue,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF71B9FD),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 60);
  }
}