import 'package:flutter/material.dart';

import '../settings/app_settings_controller.dart';

class MaUBrand extends StatelessWidget {
  const MaUBrand({super.key, this.compact = false});

  static const double _logoBoxGradientPosition = 0.5;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorOption = AppSettingsScope.of(context).selectedColor;
    final logoBoxColor = Color.lerp(
      colorOption.gradientStart,
      colorOption.gradientEnd,
      _logoBoxGradientPosition,
    )!;
    final brandAccentColor = Theme.of(context).brightness == Brightness.dark
        ? colorOption.gradientEnd
        : logoBoxColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: logoBoxColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: logoBoxColor.withAlpha(70),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/logo/ma_u_logo_5.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Ma',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              TextSpan(
                text: '-',
                style: TextStyle(
                  color: brandAccentColor,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              TextSpan(
                text: 'U',
                style: TextStyle(
                  color: brandAccentColor,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
