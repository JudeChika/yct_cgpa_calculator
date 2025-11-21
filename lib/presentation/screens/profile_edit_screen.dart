import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../domain/models/profiles.dart';
import '../../widgets/gradient_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameCtrl;
  late TextEditingController _matricCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _progCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;
    final profile = state.profile;
    
    _fullNameCtrl = TextEditingController(text: profile?.fullName ?? '');
    _matricCtrl = TextEditingController(text: profile?.matric ?? '');
    _deptCtrl = TextEditingController(text: profile?.department ?? '');
    _progCtrl = TextEditingController(text: profile?.program ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _matricCtrl.dispose();
    _deptCtrl.dispose();
    _progCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final currentProfile = context.read<ProfileCubit>().state.profile;
      if (currentProfile != null) {
        final updated = currentProfile.copyWith(
          fullName: _fullNameCtrl.text.trim(),
          matric: _matricCtrl.text.trim(),
          department: _deptCtrl.text.trim(),
          program: _progCtrl.text.trim(),
        );
        await context.read<ProfileCubit>().updateProfile(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _matricCtrl,
                  decoration: const InputDecoration(labelText: 'Matric Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deptCtrl,
                  decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _progCtrl,
                  decoration: const InputDecoration(labelText: 'Program', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                if (_saving)
                  const CircularProgressIndicator()
                else
                  GradientButton(
                    text: 'Save Profile',
                    gradient: const LinearGradient(colors: [Color(0xFF17C77A), Color(0xFF0FB66B)]),
                    onTap: _save,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
