import 'package:flutter/material.dart';

class MaUBrand extends StatelessWidget {
  const MaUBrand({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/logo/ma_u_logo_3.png',
            width: compact ? 28 : 30,
            height: compact ? 28 : 30,
            fit: BoxFit.contain,
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
                  color: colorScheme.primary,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              TextSpan(
                text: 'U',
                style: TextStyle(
                  color: colorScheme.primary,
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
