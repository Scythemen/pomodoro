import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:pomodoro/focus_clock/ring_painter_widget.dart';
import 'package:pomodoro/focus_clock/clock_setting_widget.dart';
import 'package:window_manager/window_manager.dart';

import 'clock_settings.dart';
import 'draggable_form_title_bar_widget.dart';

class FocusClock extends StatefulWidget {
  const FocusClock({super.key});

  @override
  State<StatefulWidget> createState() => _FocusClockState();
}

class _FocusClockState extends State<FocusClock> with WindowListener {
  _FocusClockState();

  Timer? _timer;
  late RingPainterSettings _ringSettings;
  Duration _counter = ClockSettings.focusDuration;
  bool _counting = false;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();

    _ringSettings = RingPainterSettings()
      ..percent = 0
      ..notCompletedColor = ClockSettings.notCompletedColor
      ..completedColor = ClockSettings.completedColor
      ..time = fmt(ClockSettings.focusDuration)
      ..timeColor = ClockSettings.timeColor;
  }

  @override
  void dispose() {
    _timer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  String fmt(Duration d) {
    var arr = d.toString().split('.')[0].split(':');
    if (int.parse(arr[0]) <= 0) arr.removeAt(0);
    return arr.join(':');
  }

  void _timerCallback(Timer t) {
    print("${t.tick} , $_counter");

    if (_counting) {
      _counter = _counter - const Duration(seconds: 1);
      if (_counter.inSeconds <= 0) {
        _counter = ClockSettings.focusDuration;
        _counting = false;
        _timer?.cancel();
        // nofification
        LocalNotification notification = LocalNotification(
          title: "Focus round completed",
          body: "Begin a short break",
        );
        notification.show();
      }

      _ringSettings.percent =
          _counter.inSeconds / ClockSettings.focusDuration.inSeconds;
      _ringSettings.time = fmt(_counter);
    }
    setState(() {});
  }

  void _startStopTimer() {
    if (_counting) {
      _timer?.cancel();
    } else {
      _ringSettings.percent =
          _counter.inSeconds / ClockSettings.focusDuration.inSeconds;
      _ringSettings.time = fmt(_counter);
      _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
    }
    _counting = !_counting;
    setState(() {});
  }

  void _resetTimer() {
    _counting = false;
    _counter = ClockSettings.focusDuration;
    _ringSettings
      ..percent = 0.0
      ..time = fmt(ClockSettings.focusDuration);

    _timer?.cancel();
    setState(() {});
  }

  void _onCloseBottonPress() {
    windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClockSettings.backgroundColor,
      body: Center(
          child: Column(
        children: [
          DraggableFormTitleBarWidget(
            title: Text(
              "Pomodoro",
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 2,
                  fontSize: ClockSettings.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: ClockSettings.titleColor),
            ),
            endWidget: IconButton(
                onPressed: _onCloseBottonPress,
                icon: Icon(
                  Icons.close,
                  color: ClockSettings.titleColor,
                )),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                  child: RingPainterWidget(
                    key: UniqueKey(),
                    settings: _ringSettings,
                  ),
                ),
                // Text(_counter.toString()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      // tooltip: "Reset",
                      color: ClockSettings.buttonColor,
                    ),
                    IconButton(
                      icon: _counting
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                      color: ClockSettings.buttonColor,
                      // tooltip: _counting ? "Pause" : "Start",
                      onPressed: _startStopTimer,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: ClockSettings.buttonColor,
                      // tooltip: "Settings",
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ClockSettingWidget();
                        }));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }
}
