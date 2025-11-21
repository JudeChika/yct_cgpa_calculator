import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/gradient_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _redirecting = false;

  final _fullNameCtrl = TextEditingController();
  final _matricCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _programCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _redirecting = false;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _fullNameCtrl.text.trim(),
        'matric': _matricCtrl.text.trim(),
        'department': _deptCtrl.text.trim(),
        'program': _programCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Success — show a redirect loader then navigate automatically to LoginScreen.
      if (!mounted) return;
      setState(() {
        _redirecting = true;
      });

      // Short UX delay so user sees the loader (you asked for loader while waiting for redirection)
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'The email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Provided email is invalid.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      // ignore: avoid_print
      print('Registration Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
        _loading = false;
      });
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _matricCtrl.dispose();
    _deptCtrl.dispose();
    _programCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Create Account', style: theme.textTheme.headlineMedium).animate().fadeIn(),
              const SizedBox(height: 8),
              Text('Fill in your details below to register', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameCtrl,
                      decoration: _inputDecoration('Full name', Icons.person),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _matricCtrl,
                      decoration: _inputDecoration('Matric Number', Icons.badge),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter matric number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deptCtrl,
                      decoration: _inputDecoration('Department', Icons.school),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter department' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _programCtrl,
                      decoration: _inputDecoration('Program / Class', Icons.class_),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter program/class' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: _inputDecoration('Phone Number', Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter phone number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: _inputDecoration('Email', Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: _inputDecoration('Password (must be at least 6 characters)', Icons.lock),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    if (_loading) const Center(child: CircularProgressIndicator()),
                    if (!_loading && !_redirecting)
                      GradientButton(
                        text: 'Create Account',
                        gradient: const LinearGradient(colors: [Color(0xFF18A85E), Color(0xFF0E9A4B)]),
                        onTap: _register,
                      ).animate().fadeIn(),
                    if (_redirecting)
                      Column(
                        children: const [
                          SizedBox(height: 12),
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Redirecting to Login...'),
                        ],
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
