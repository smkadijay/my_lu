import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

const kPrimaryColor = Colors.blue;

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Already a member?',
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoginPage())),
                    child: const Text('Login'),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const RegistrationForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final c = <String, TextEditingController>{
    'first': TextEditingController(),
    'last': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'pass': TextEditingController(),
    'confirm': TextEditingController(),
  };
  final _obscure = {'pass': true, 'confirm': true};
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;
      final user = await auth.createUserWithEmailAndPassword(
          email: c['email']!.text.trim(), password: c['pass']!.text.trim());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .set({
        'firstName': c['first']!.text.trim(),
        'lastName': c['last']!.text.trim(),
        'phone': c['phone']!.text.trim(),
        'email': c['email']!.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration Successful! Verify your email.')));
      _formKey.currentState!.reset();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildField(String label,
      {bool pass = false, bool confirm = false}) {
    final key = pass ? 'pass' : confirm ? 'confirm' : label.toLowerCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: c[key],
        obscureText: pass || confirm ? _obscure[key]! : false,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Enter $label';
          if (label == 'Email' &&
              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
            return 'Invalid email';
          }
          if (label == 'Password' && v.length < 6) {
            return 'Min 6 characters with letters & numbers';
          }
          if (label == 'Confirm Password' && v != c['pass']!.text) {
            return 'Passwords do not match';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: label,
          suffixIcon: (pass || confirm)
              ? IconButton(
                  icon: Icon(_obscure[key]!
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscure[key] = !_obscure[key]!),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField('First Name'),
          _buildField('Last Name'),
          _buildField('Email'),
          _buildField('Phone'),
          _buildField('Password', pass: true),
          _buildField('Confirm Password', confirm: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _register,
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: const Size(double.infinity, 50)),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Register'),
          )
        ],
      ),
    );
  }
}
