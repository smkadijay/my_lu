import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool searchable = false;
  String acceptMessages = 'contacts';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data() ?? {};
    setState(() {
      searchable = data['searchable'] ?? false;
      acceptMessages = data['acceptMessages'] ?? 'contacts';
      loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'searchable': searchable,
      'acceptMessages': acceptMessages,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Allow others to find me (searchable)'),
              value: searchable,
              onChanged: (v) => setState(() => searchable = v),
            ),
            const SizedBox(height: 20),
            const Text('Who can send you messages?', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'everyone',
              groupValue: acceptMessages,
              onChanged: (v) => setState(() => acceptMessages = v!),
            ),
            RadioListTile<String>(
              title: const Text('Only my contacts'),
              value: 'contacts',
              groupValue: acceptMessages,
              onChanged: (v) => setState(() => acceptMessages = v!),
            ),
            RadioListTile<String>(
              title: const Text('No one'),
              value: 'noone',
              groupValue: acceptMessages,
              onChanged: (v) => setState(() => acceptMessages = v!),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
