import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yct_cgpa_calculator/bloc/dashboard/dashboard_cubit.dart';
import 'package:yct_cgpa_calculator/bloc/profile/profile_cubit.dart';
import 'package:yct_cgpa_calculator/bloc/semester/semesters_cubit.dart';
import 'package:yct_cgpa_calculator/presentation/screens/semester_list_screen.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/sparkline.dart';
import 'profile_edit_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileCubit>().state;
    final profile = profileState.profile;
    final displayName = profile?.fullName ?? FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'Student';
    final matric = profile?.matric ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
          ),
          IconButton(
            tooltip: 'Semesters',
            icon: const Icon(Icons.school),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SemestersListScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading || state.status == DashboardStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == DashboardStatus.failure) {
              return Center(child: Text(state.message ?? 'Failed to load dashboard'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Y',
                          style: const TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green.shade700))
                              .animate()
                              .fadeIn(delay: 120.ms),
                          const SizedBox(height: 6),
                          Text(displayName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))
                              .animate()
                              .slideY(delay: 160.ms),
                          const SizedBox(height: 4),
                          Text(matric, style: Theme.of(context).textTheme.titleMedium).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // KPI Row
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: 'CGPA',
                          value: state.cgpa.toStringAsFixed(2),
                          subtitle: '${state.semestersCount} semesters',
                          gradient: const LinearGradient(colors: [Color(0xFF2BB673), Color(0xFF1E8F4E)]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          title: 'TCU',
                          value: '${state.totalTcu}',
                          subtitle: 'Total credit units',
                          gradient: const LinearGradient(colors: [Color(0xFF64D98B), Color(0xFF2BB673)]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          title: 'TQP',
                          value: state.totalTqp.toStringAsFixed(2),
                          subtitle: 'Total quality points',
                          gradient: const LinearGradient(colors: [Color(0xFF18A85E), Color(0xFF0E9A4B)]),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 220.ms),

                  const SizedBox(height: 18),

                  // GPA history sparkline + actions
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('GPA History', style: Theme.of(context).textTheme.titleMedium),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SemestersListScreen())),
                                child: const Text('View all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: Sparkline(
                              values: state.gpaHistory,
                              lineColor: Colors.green.shade700,
                              fillColor: Colors.green.shade100.withOpacity(0.8),
                            ),
                          )
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 280.ms),

                  const SizedBox(height: 18),

                  // CTA row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, padding: const EdgeInsets.symmetric(vertical: 14)),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Semester'),
                          onPressed: () {
                            // navigate to semester editor (create new)
                            final semCount = context.read<SemestersCubit>().state.semesters.length;
                            final next = semCount + 1;
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SemestersListScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text('Edit Profile'),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 320.ms),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}