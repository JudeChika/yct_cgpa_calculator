import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../../domain/models/profiles.dart';
import '../../widgets/gradient_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _matric;
  late TextEditingController _dept;
  late TextEditingController _program;
  late TextEditingController _phone;
  late TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _matric = TextEditingController();
    _dept = TextEditingController();
    _program = TextEditingController();
    _phone = TextEditingController();
    _email = TextEditingController();
    final state = context.read<ProfileCubit>().state;
    if (state.profile != null) {
      _populate(state.profile!);
    }
  }

  void _populate(Profile p) {
    _name.text = p.fullName;
    _matric.text = p.matric;
    _dept.text = p.department;
    _program.text = p.program;
    _phone.text = p.phone;
    _email.text = p.email;
  }

  @override
  void dispose() {
    _name.dispose();
    _matric.dispose();
    _dept.dispose();
    _program.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save(Profile profile) {
    if (!_formKey.currentState!.validate()) return;
    final updated = profile.copyWith(
      fullName: _name.text.trim(),
      matric: _matric.text.trim(),
      department: _dept.text.trim(),
      program: _program.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
    );
    context.read<ProfileCubit>().updateProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.loaded && state.profile != null) {
            // repopulate if updated
            _populate(state.profile!);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
          }
          if (state.status == ProfileStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfileStatus.notFound) {
            return const Center(child: Text('No profile found'));
          }
          final profile = state.profile ??
              Profile(
                uid: '',
                fullName: '',
                matric: '',
                department: '',
                program: '',
                phone: '',
                email: '',
              );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Edit Profile', style: Theme.of(context).textTheme.headlineSmall).animate().fadeIn(),
                  const SizedBox(height: 12),
                  TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _matric, decoration: const InputDecoration(labelText: 'Matric number')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _dept, decoration: const InputDecoration(labelText: 'Department')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _program, decoration: const InputDecoration(labelText: 'Program/Class')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Save',
                    gradient: const LinearGradient(colors: [Color(0xFF18A85E), Color(0xFF0E9A4B)]),
                    onTap: () => _save(profile),
                  ).animate().fadeIn(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}