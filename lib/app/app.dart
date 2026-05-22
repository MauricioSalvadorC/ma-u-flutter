import 'package:flutter/material.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';

class UniversityCompanionApp extends StatefulWidget {
  const UniversityCompanionApp({super.key});

  @override
  State<UniversityCompanionApp> createState() => _UniversityCompanionAppState();
}

class _UniversityCompanionAppState extends State<UniversityCompanionApp> {
  final _settingsController = AppSettingsController();

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
        return AppSettingsScope(
          controller: _settingsController,
          child: MaterialApp(
            title: 'MA-U',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(_settingsController.seedColor),
            darkTheme: AppTheme.dark(_settingsController.seedColor),
            themeMode: _settingsController.themeMode,
            home: const DashboardScreen(),
          ),
        );
      },
    );
  }
}
