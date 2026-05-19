import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elbi_eats/models/user/user_model.dart';
import 'package:elbi_eats/providers/auth/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _discoveryRadius;
  late bool _notifChat;
  late bool _notifClaim;
  late bool _notifClaimStatus;
  late bool _notifPosting;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _discoveryRadius = user.discoveryRadius ?? 5.0;
      _notifChat = user.notificationPreferences?['chat'] ?? true;
      _notifClaim = user.notificationPreferences?['claim'] ?? true;
      _notifClaimStatus = user.notificationPreferences?['claimStatus'] ?? true;
      _notifPosting = user.notificationPreferences?['posting'] ?? true;
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user != null) {
        await authProvider.updateUserSettings(
          discoveryRadius: _discoveryRadius,
          notificationPreferences: {
            'chat': _notifChat,
            'claim': _notifClaim,
            'claimStatus': _notifClaimStatus,
            'posting': _notifPosting,
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discovery Radius Section
            const Text(
              'Discovery Radius',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Radius:'),
                      Text(
                        '${_discoveryRadius.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _discoveryRadius,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    onChanged: (value) {
                      setState(() => _discoveryRadius = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will receive notifications for items within this radius that match your interests.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Notification Preferences Section
            const Text(
              'Notification Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Chat Notifications
            _buildNotificationToggle(
              icon: Icons.chat_bubble_outline,
              title: 'Chat Messages',
              subtitle: 'Notifications for new messages',
              value: _notifChat,
              onChanged: (value) {
                setState(() => _notifChat = value);
              },
            ),

            const SizedBox(height: 12),

            // Claim Notifications
            _buildNotificationToggle(
              icon: Icons.assignment_outlined,
              title: 'New Claims',
              subtitle: 'When someone claims your item',
              value: _notifClaim,
              onChanged: (value) {
                setState(() => _notifClaim = value);
              },
            ),

            const SizedBox(height: 12),

            // Claim Status Notifications
            _buildNotificationToggle(
              icon: Icons.check_circle_outline,
              title: 'Claim Updates',
              subtitle: 'When a claim is accepted or rejected',
              value: _notifClaimStatus,
              onChanged: (value) {
                setState(() => _notifClaimStatus = value);
              },
            ),

            const SizedBox(height: 12),

            // Posting Notifications
            _buildNotificationToggle(
              icon: Icons.location_on_outlined,
              title: 'Nearby Items',
              subtitle: 'New items posted near you',
              value: _notifPosting,
              onChanged: (value) {
                setState(() => _notifPosting = value);
              },
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}