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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClockSettings.backgroundColor,
      drawerScrimColor: ClockSettings.titleColor,
      // appBar: AppBar(
      //   shadowColor: null,
      //   elevation: 0,
      //   backgroundColor: ClockSettings.backgroundColor,
      //   foregroundColor: ClockSettings.titleColor,
      //   title: DragToMoveArea(
      //       child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: const [Text('Settings '), Text(' ')])),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DraggableFormTitleBarWidget(
            startWidget: IconButton(
                onPressed: () => {Navigator.pop(context)},
                padding: const EdgeInsets.fromLTRB(10, 15, 15, 0),
                icon: Icon(
                  Icons.arrow_back,
                  color: ClockSettings.titleColor,
                )),
            title: Text(
              "Settings",
              style: TextStyle(
                  height: 2,
                  fontSize: ClockSettings.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: ClockSettings.titleColor),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          ),
          Form(
              child: Scrollbar(
                  child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(
                  "Focus minutes: $_focusMinutes",
                  style:
                      TextStyle(color: ClockSettings.titleColor, fontSize: 16),
                ),
                Slider(
                  min: 1,
                  max: 120,
                  divisions: 24,
                  value: _focusMinutes.toDouble(),
                  onChanged: (value) {
                    ClockSettings.focusDuration =
                        Duration(minutes: value.toInt());
                    setState(() {
                      _focusMinutes = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ))),
        ],
      ),
    );
  }
}
