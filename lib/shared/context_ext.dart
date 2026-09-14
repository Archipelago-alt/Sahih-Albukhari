import 'package:flutter/material.dart';

import '../core/arabic/arabic_normalizer.dart';
import '../l10n/gen/app_localizations.dart';

extension ContextExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isArabicUi => Localizations.localeOf(this).languageCode == 'ar';

  /// Formats an interface number with the digits of the current language.
  String number(int n) => isArabicUi ? ArabicNormalizer.toArabicDigits('$n') : '$n';

  /// Converts the digits of an interface string to the current language.
  String digits(String s) => isArabicUi ? ArabicNormalizer.toArabicDigits(s) : ArabicNormalizer.toWesternDigits(s);

  void showSnack(String message) => ScaffoldMessenger.of(this)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<bool> confirm({
    required String title,
    required String message,
    String? confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel ?? context.l10n.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
