import 'package:flutter/material.dart';

import 'app_settings_repository.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({required AppSettingsRepository repository})
    : _repository = repository;

  final AppSettingsRepository _repository;
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppPalette.defaultColor;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get isLoaded => _isLoaded;
  AppColorOption get selectedColor => AppPalette.optionFor(_seedColor);

  Future<void> load() async {
    final savedThemeMode = await _repository.getThemeMode();
    final savedSeedColor = await _repository.getSeedColor();

    _themeMode = savedThemeMode ?? _themeMode;
    _seedColor = savedSeedColor ?? _seedColor;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
    await _repository.setThemeMode(themeMode);
  }

  Future<void> setSeedColor(Color seedColor) async {
    if (_seedColor == seedColor) {
      return;
    }

    _seedColor = seedColor;
    notifyListeners();
    await _repository.setSeedColor(seedColor);
  }
}

class AppPalette {
  const AppPalette._();

  static const defaultColor = Color(0xFF0F766E);

  static const colors = [
    AppColorOption(
      name: 'Menta',
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
      name: 'Cielo',
      color: Color(0xFF0284C7),
      gradientStart: Color(0xFF075985),
      gradientEnd: Color(0xFF7DD3FC),
    ),
    AppColorOption(
      name: 'Indigo',
      color: Color(0xFF4F46E5),
      gradientStart: Color(0xFF312E81),
      gradientEnd: Color(0xFF818CF8),
    ),
    AppColorOption(
      name: 'Violeta',
      color: Color(0xFF7C3AED),
      gradientStart: Color(0xFF3B0764),
      gradientEnd: Color(0xFFA78BFA),
    ),
    AppColorOption(
      name: 'Magenta',
      color: Color(0xFFC026D3),
      gradientStart: Color(0xFF701A75),
      gradientEnd: Color(0xFFE879F9),
    ),
    AppColorOption(
      name: 'Fucsia',
      color: Color(0xFFDB2777),
      gradientStart: Color(0xFF831843),
      gradientEnd: Color(0xFFF9A8D4),
    ),
    AppColorOption(
      name: 'Rosa',
      color: Color(0xFFBE123C),
      gradientStart: Color(0xFF701A32),
      gradientEnd: Color(0xFFFB7185),
    ),
    AppColorOption(
      name: 'Rojo',
      color: Color(0xFFDC2626),
      gradientStart: Color(0xFF7F1D1D),
      gradientEnd: Color(0xFFF87171),
    ),
    AppColorOption(
      name: 'Coral',
      color: Color(0xFFDC6B19),
      gradientStart: Color(0xFF7C2D12),
      gradientEnd: Color(0xFFF97316),
    ),
    AppColorOption(
      name: 'Ambar',
      color: Color(0xFFD97706),
      gradientStart: Color(0xFF78350F),
      gradientEnd: Color(0xFFFBBF24),
    ),
    AppColorOption(
      name: 'Lima',
      color: Color(0xFF4D7C0F),
      gradientStart: Color(0xFF1A2E05),
      gradientEnd: Color(0xFFA3E635),
    ),
    AppColorOption(
      name: 'Verde',
      color: Color(0xFF16A34A),
      gradientStart: Color(0xFF14532D),
      gradientEnd: Color(0xFF86EFAC),
    ),
    AppColorOption(
      name: 'Bosque',
      color: Color(0xFF15803D),
      gradientStart: Color(0xFF052E16),
      gradientEnd: Color(0xFF4ADE80),
    ),
    AppColorOption(
      name: 'Grafito',
      color: Color(0xFF475569),
      gradientStart: Color(0xFF0F172A),
      gradientEnd: Color(0xFF94A3B8),
    ),
    AppColorOption(
      name: 'Carbon',
      color: Color(0xFF27272A),
      gradientStart: Color(0xFF09090B),
      gradientEnd: Color(0xFF71717A),
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
