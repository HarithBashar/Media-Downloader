import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// A user-selectable application language.
///
/// To add a new language in the future:
///   1. Create `lib/l10n/app_<code>.arb` (copy `app_en.arb` and translate).
///   2. Run `flutter gen-l10n`.
///   3. Add an [AppLanguage] entry below with its native name.
/// Everything else (locale switching, RTL, fonts) is handled automatically.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    this.isRtl = false,
  });

  /// ISO 639-1 language code (e.g. 'en', 'ar').
  final String code;

  /// The language's name written in that language (shown in the picker).
  final String nativeName;

  /// Whether this language is written right-to-left.
  final bool isRtl;

  Locale get locale => Locale(code);
}

/// All languages the user can switch between.
const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'en', nativeName: 'English'),
  AppLanguage(code: 'ar', nativeName: 'العربية', isRtl: true),
];

/// Resolves a stored language code to an [AppLanguage], defaulting to English.
AppLanguage languageForCode(String code) {
  return supportedLanguages.firstWhere(
    (l) => l.code == code,
    orElse: () => supportedLanguages.first,
  );
}

/// Convenient access to the current [AppLocalizations] from any widget.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
