import 'package:flutter/cupertino.dart';

enum AppThemeMode { system, light, dark }

extension AppThemeModeLabel on AppThemeMode {
  String get label => switch (this) {
        AppThemeMode.system => 'Automatic',
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
      };

  String get detail => switch (this) {
        AppThemeMode.system => 'Match your device setting',
        AppThemeMode.light => 'Always light',
        AppThemeMode.dark => 'Always dark',
      };

  IconData get icon => switch (this) {
        AppThemeMode.system => CupertinoIcons.circle_lefthalf_fill,
        AppThemeMode.light => CupertinoIcons.sun_max_fill,
        AppThemeMode.dark => CupertinoIcons.moon_fill,
      };
}

/// Selected appearance mode. Not persisted between launches.
class ThemeController extends ValueNotifier<AppThemeMode> {
  ThemeController._() : super(AppThemeMode.system);

  static final ThemeController instance = ThemeController._();

  void set(AppThemeMode mode) => value = mode;

  Brightness? get brightness => switch (value) {
        AppThemeMode.system => null,
        AppThemeMode.light => Brightness.light,
        AppThemeMode.dark => Brightness.dark,
      };
}
