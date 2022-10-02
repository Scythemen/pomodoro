import 'package:flutter/material.dart';
import 'package:pomodoro/focus_clock/clock_settings.dart';
import 'package:pomodoro/focus_clock/draggable_form_title_bar_widget.dart';
import 'package:window_manager/window_manager.dart';

class ClockSettingWidget extends StatefulWidget {
  const ClockSettingWidget({super.key});

  @override
  State<StatefulWidget> createState() => _StatefulSettingWidget();
}

class _StatefulSettingWidget extends State<ClockSettingWidget>
    with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  int _focusMinutes = ClockSettings.focusDuration.inMinutes;
  int _breakMinutes = ClockSettings.breakDuration.inMinutes;
  int _repeat = ClockSettings.repeat;

  @override
  Widget build(BuildContext context) {
    var themeList = ClockSettings.themes.keys.map((k) {
      return CheckboxListTile(
        side: MaterialStateBorderSide.resolveWith(
          (states) => const BorderSide(width: 1.0, color: Colors.transparent),
        ),
        value: ClockSettings.theme.name == k,
        onChanged: (value) {
          ClockSettings.theme = ClockSettings.getThemeByName(k);
          setState(() {});
        },
        title: Text(
          k,
          style: TextStyle(
            color: ClockSettings.themes[k]?.titleColor,
          ),
        ),
        checkColor: ClockSettings.themes[k]?.buttonColor,
        activeColor: Colors.transparent,
        secondary: Icon(
          Icons.color_lens,
          color: ClockSettings.themes[k]?.ringForegroundColor,
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: ClockSettings.theme.backgroundColor,
      drawerScrimColor: ClockSettings.theme.titleColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DraggableFormTitleBarWidget(
            startWidget: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  ClockSettings.SaveConfig();
                },
                padding: const EdgeInsets.fromLTRB(10, 15, 15, 0),
                icon: Icon(
                  Icons.arrow_back,
                  color: ClockSettings.theme.titleColor,
                )),
            title: Text(
              "Settings",
              style: TextStyle(
                  height: 2,
                  fontSize: ClockSettings.theme.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: ClockSettings.theme.titleColor),
            ),
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 400, maxHeight: 440),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    ),
                    Text(
                      "Focus on a task $_focusMinutes minutes",
                      style: TextStyle(
                          color: ClockSettings.theme.titleColor, fontSize: 16),
                    ),
                    Slider(
                      min: 1,
                      max: 120,
                      // divisions: 24,
                      value: _focusMinutes.toDouble(),
                      onChanged: (value) {
                        ClockSettings.focusDuration =
                            Duration(minutes: value.toInt());
                        setState(() {
                          _focusMinutes = value.toInt();
                        });
                      },
                    ),
                    Text(
                      "Then enjoy a $_breakMinutes-minute break",
                      style: TextStyle(
                          color: ClockSettings.theme.titleColor, fontSize: 16),
                    ),
                    Slider(
                      min: 1,
                      max: 30,
                      // divisions: 29,
                      value: _breakMinutes.toDouble(),
                      onChanged: (value) {
                        ClockSettings.breakDuration =
                            Duration(minutes: value.toInt());
                        setState(() {
                          _breakMinutes = value.toInt();
                        });
                      },
                    ),
                    Text(
                      "Repeat $_repeat pomodoros",
                      style: TextStyle(
                          color: ClockSettings.theme.titleColor, fontSize: 16),
                    ),
                    Slider(
                      min: 1,
                      max: 4,
                      // divisions: 3,
                      value: _repeat.toDouble(),
                      onChanged: (value) {
                        ClockSettings.repeat = value.toInt();
                        setState(() {
                          _repeat = value.toInt();
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                    ),
                    Text(
                      "${ClockSettings.themes.length} Themes:",
                      style: TextStyle(
                          color: ClockSettings.theme.titleColor, fontSize: 16),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: themeList,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
