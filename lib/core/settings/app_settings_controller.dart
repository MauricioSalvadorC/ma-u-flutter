import 'package:flutter/material.dart';

class AppSettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppPalette.defaultColor;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  AppColorOption get selectedColor => AppPalette.optionFor(_seedColor);

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
  }

  void setSeedColor(Color seedColor) {
    if (_seedColor == seedColor) {
      return;
    }

    _seedColor = seedColor;
    notifyListeners();
  }
}

class AppPalette {
  const AppPalette._();

  static const defaultColor = Color(0xFF0F766E);

  static const colors = [
    AppColorOption(
      name: 'Teal',
      color: Color(0xFF0F766E),
      gradientStart: Color(0xFF052E2B),
      gradientEnd: Color(0xFF14B8A6),
    ),
    AppColorOption(
      name: 'Azul',
      color: Color(0xFF2563EB),
      gradientStart: Color(0xFF102A6B),
      gradientEnd: Color(0xFF38BDF8),
    ),
    AppColorOption(
      name: 'Violeta',
      color: Color(0xFF7C3AED),
      gradientStart: Color(0xFF3B0764),
      gradientEnd: Color(0xFFA78BFA),
    ),
    AppColorOption(
      name: 'Coral',
      color: Color(0xFFDC6B19),
      gradientStart: Color(0xFF7C2D12),
      gradientEnd: Color(0xFFF97316),
    ),
    AppColorOption(
      name: 'Rosa',
      color: Color(0xFFBE123C),
      gradientStart: Color(0xFF701A32),
      gradientEnd: Color(0xFFFB7185),
    ),
    AppColorOption(
      name: 'Lima',
      color: Color(0xFF4D7C0F),
      gradientStart: Color(0xFF1A2E05),
      gradientEnd: Color(0xFFA3E635),
    ),
  ];

  static AppColorOption optionFor(Color color) {
    return colors.firstWhere(
      (option) => option.color == color,
      orElse: () => colors.first,
    );
  }
}

class AppColorOption {
  const AppColorOption({
    required this.name,
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String name;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    required AppSettingsController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope was not found in the tree.');
    return scope!.notifier!;
  }
}
