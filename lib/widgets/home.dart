import 'package:app_tact/services/post_login_onboarding_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/widgets/main_navigation.dart';
import 'package:app_tact/widgets/onboarding_flow_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isResolvingEntry = true;
  bool _showOnboarding = false;
  bool _hasResolvedEntry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasResolvedEntry) return;
      _hasResolvedEntry = true;
      _resolveEntryScreen();
    });
  }

  Future<void> _resolveEntryScreen() async {
    final onboardingService = PostLoginOnboardingService.instance;
    final shouldShowOnboarding = await onboardingService.shouldShowOnboarding();
    if (!mounted) return;
    setState(() {
      _showOnboarding = shouldShowOnboarding;
      _isResolvingEntry = false;
    });
  }

  void _handleOnboardingCompleted() {
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
      _isResolvingEntry = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isResolvingEntry) {
      return Container(
        decoration: BoxDecoration(
          gradient: context.screenGradient,
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingFlowScreen(
        onCompleted: _handleOnboardingCompleted,
      );
    }

    return const MainNavigationScreen();
  }
}
