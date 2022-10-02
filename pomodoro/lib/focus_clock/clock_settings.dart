import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class ClockSettings {
  static Duration focusDuration = const Duration(minutes: 25);
  static Duration breakDuration = const Duration(minutes: 5);
  static int repeat = 4;
  

  static ThemeSettings theme = ThemeSettings('default');

  static ThemeSettings getThemeByName(String name) {
    var t = themes[name];
    if (t != null) {
      return t;
    } else {
      return ThemeSettings('default');
    }
  }

  static final themes = {
    'default': ThemeSettings('default'),
    'rally': ThemeSettings('rally')
      ..backgroundColor = const Color(0xFFDDFCEF)
      ..buttonColor = const Color(0xFF49B782)
      ..closeButtonColor = const Color(0xFFADE1CD)
      ..ringBackgroundColor = const Color(0xFFADE1CD)
      ..ringForegroundColor = const Color(0xFF46B07D)
      ..ringTimeTextColor = const Color(0xFF49B782)
      ..titleColor = const Color(0xFF1E5D57),
    'shrine': ThemeSettings('shrine')
      ..backgroundColor = const Color(0xFFFADBD1)
      ..buttonColor = const Color(0xFF40272A)
      ..closeButtonColor = const Color(0xFFBFA19B)
      ..ringBackgroundColor = const Color(0xFFBFA19B)
      ..ringForegroundColor = const Color.fromARGB(255, 137, 113, 109)
      ..ringTimeTextColor = const Color(0xFF40272A)
      ..titleColor = const Color(0xFF40272A),
    'crane': ThemeSettings('crane')
      ..backgroundColor = const Color(0xFFFAF6F8)
      ..buttonColor = const Color(0xFF600B4A)
      ..closeButtonColor = const Color(0xFFF6E2EE)
      ..ringBackgroundColor = const Color(0xFFF6E2EE)
      ..ringForegroundColor = const Color(0xFFAC7BA4)
      ..ringTimeTextColor = const Color(0xFF600B4A)
      ..titleColor = const Color(0xFF600B4A),
    'fortnightly': ThemeSettings('fortnightly')
      ..backgroundColor = const Color(0xFFEEEEEE)
      ..buttonColor = const Color(0xFF666666)
      ..closeButtonColor = const Color(0xFFD6D6D6)
      ..ringBackgroundColor = const Color(0xFFD6D6D6)
      ..ringForegroundColor = const Color(0xFF555555)
      ..ringTimeTextColor = const Color(0xFF555555)
      ..titleColor = const Color(0xFF666666)
  };

  static Future SaveConfig() async {
    var map = {
      'theme': ClockSettings.theme.name,
      'focusDuration': ClockSettings.focusDuration.toString(),
      'breakDuration': ClockSettings.breakDuration.toString(),
      'repeat': ClockSettings.repeat,
    };

    // var j = jsonEncode(map);
    var j = const JsonEncoder.withIndent('   ').convert(map);

    var f = File(await _getConfigFile());
    return f.writeAsStringSync(j, encoding: utf8);
  }

  static Future<String> _getConfigFile() async {
    final d = await getApplicationDocumentsDirectory();
    return "${d.path}/pomodoro.config.josn";
  }

  static int _getDurationMinuteFromString(String d) {
    if (d.isEmpty) return 1;
    var m = d.split(':')[1];
    return int.parse(m);
  }

  static Future ReadConfig() async {
    var f = File(await _getConfigFile());
    if (await f.exists()) {
      try {
        var json = f.readAsStringSync(encoding: utf8);
        var m = jsonDecode(json);

        ClockSettings.focusDuration =
            Duration(minutes: _getDurationMinuteFromString(m['focusDuration']));
        ClockSettings.breakDuration =
            Duration(minutes: _getDurationMinuteFromString(m['breakDuration']));
        ClockSettings.repeat = m['repeat'];
        ClockSettings.theme = getThemeByName(m['theme']);
      } catch (ex) {
        debugPrint(ex.toString());
        log(ex.toString());
      } finally {}
    }
  }
}

class ThemeSettings {
  ThemeSettings(String name) {
    _name = name;
  }

  String _name = "default";
  String get name => _name;

  Color backgroundColor = const Color.fromARGB(255, 51, 75, 107);
  Color titleColor = const Color.fromARGB(255, 255, 255, 255);
  Color ringTimeTextColor = const Color.fromARGB(255, 255, 255, 255);
  Color ringBackgroundColor = const Color.fromARGB(255, 177, 177, 177);
  Color ringForegroundColor = const Color.fromARGB(255, 235, 73, 73);
  Color buttonColor = const Color.fromARGB(255, 255, 255, 255);
  Color closeButtonColor = const Color.fromARGB(255, 177, 177, 177);
  double titleFontSize = 24.0;
}
