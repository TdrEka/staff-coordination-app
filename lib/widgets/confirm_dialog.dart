import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = '',
    this.cancelLabel = '',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => context.pop(false),
          style: TextButton.styleFrom(foregroundColor: AppTheme.onSurfaceVariant),
          child: Text(
            cancelLabel.isEmpty ? l10n.cancel : cancelLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.error,
            foregroundColor: AppTheme.onPrimary,
          ),
          onPressed: () => context.pop(true),
          child: Text(
            confirmLabel.isEmpty ? l10n.confirm : confirmLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }

  static Future<bool> ask(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = '',
    String cancelLabel = '',
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
        );
      },
    );
    return result ?? false;
  }
}

