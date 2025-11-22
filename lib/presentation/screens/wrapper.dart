import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_screen.dart';
import 'welcome_screen.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/profile/profile_cubit.dart';

/// Wrapper uses the AuthBloc state to decide the app's landing screen.
/// This version uses AnimatedSwitcher but ensures children have a defined size
/// during the transition by wrapping them with SizedBox.expand().
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        Widget child;
        switch (state.status) {
          case AuthStatus.authenticated:
            final profileState = context.watch<ProfileCubit>().state;
            final profile = profileState.profile;
            final profileMap = {
              'fullName': profile?.fullName,
              'matric': profile?.matric,
              'department': profile?.department,
              'program': profile?.program,
              'phone': profile?.phone,
              'email': profile?.email,
            };
            child = HomeScreen(profile: profileMap);
            break;
          case AuthStatus.unauthenticated:
            child = const WelcomeScreen();
            break;
          case AuthStatus.unknown:
          default:
            child = const Scaffold(body: Center(child: CircularProgressIndicator()));
            break;
        }

        // Use AnimatedSwitcher but make sure transitition child fills available space.
        // Wrapping with SizedBox.expand ensures children have a size during animation
        // and prevents "hit test with no size" errors when swapping full-screen widgets.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (widget, animation) {
            final offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOut)).animate(animation);

            // SizedBox.expand guarantees the child has the available size during the transition.
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: SizedBox.expand(child: widget),
              ),
            );
          },
          // Key by auth status so AnimatedSwitcher knows when to transition.
          child: KeyedSubtree(key: ValueKey(state.status), child: child),
        );
      },
    );
  }
}