import 'package:flutter/material.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/settings/app_settings_repository.dart';
import '../core/theme/app_theme.dart';
import '../data/database/app_database_provider.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

class UniversityCompanionApp extends StatefulWidget {
  const UniversityCompanionApp({super.key});

  @override
  State<UniversityCompanionApp> createState() => _UniversityCompanionAppState();
}

class _UniversityCompanionAppState extends State<UniversityCompanionApp> {
  late final AppSettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController(
      repository: AppSettingsRepository(AppDatabaseProvider.instance),
    );
    _settingsController.load();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, _) {
        final home = !_settingsController.isLoaded
            ? const _AppLoadingScreen()
            : _settingsController.onboardingCompleted
            ? const DashboardScreen()
            : OnboardingScreen(
                onComplete: _settingsController.completeOnboarding,
              );

        return AppSettingsScope(
          controller: _settingsController,
          child: MaterialApp(
            title: 'Ma-U',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(_settingsController.seedColor),
            darkTheme: AppTheme.dark(_settingsController.seedColor),
            themeMode: _settingsController.themeMode,
            home: home,
          ),
        );
      },
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
