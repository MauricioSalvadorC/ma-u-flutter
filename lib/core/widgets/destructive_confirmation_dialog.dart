import 'package:flutter/material.dart';

class DestructiveConfirmationDialog extends StatelessWidget {
  const DestructiveConfirmationDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Eliminar',
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Eliminar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DestructiveConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_outlined, color: colorScheme.error),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.delete_outline),
          label: Text(confirmLabel),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
        ),
      ],
    );
  }
}
