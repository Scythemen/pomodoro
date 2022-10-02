import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:pomodoro/focus_clock/ring_painter_widget.dart';
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

  int _status = 0;
  int _repeat = 1;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();

    _ringSettings = RingPainterSettings()
      ..percent = 0
      ..time = fmt(ClockSettings.focusDuration);
    syncColorSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  void syncColorSettings() {
    _ringSettings
      ..ringBackgroundColor = ClockSettings.theme.ringBackgroundColor
      ..ringForegroundColor = ClockSettings.theme.ringForegroundColor
      ..ringTimeTextColor = ClockSettings.theme.ringTimeTextColor
      ..ringTimeTextColor = ClockSettings.theme.ringTimeTextColor;
  }

  String fmt(Duration d) {
    var arr = d.toString().split('.')[0].split(':');
    if (int.parse(arr[0]) <= 0) arr.removeAt(0);
    return arr.join(':');
  }

  void _timerCallback(Timer t) async {
    debugPrint("timer tick: ${t.tick} , $_counter");

    if (_counting) {
      _counter = _counter - const Duration(seconds: 1);
      _updateRing();
      if (_counter.inSeconds <= 0) {
        _counting = false;
        _timer?.cancel();

        _notify(_status);

        // await Future.delayed(const Duration(seconds: 3));

        var end = _nextCounter();
        // is this the end?
        if (!end) {
          _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
          _counting = true;
        }
      }
    }
  }

  void _notify(int currentStatus) {
    LocalNotification notification = LocalNotification(
      identifier: "Pomodoro",
      title: "Round completed",
      body: "Begin a short break",
    );
    if (currentStatus == 0) {
      notification.title = "Focus round completed";
      notification.body =
          "Please take a short break(${ClockSettings.breakDuration.inMinutes} minutes)";
    } else {
      notification.title = "Break finished";
      notification.body =
          "Start focusing for ${ClockSettings.focusDuration.inMinutes} minutes";
    }
    notification.show();
  }

  void _updateRing() {
    // focus
    if (_status == 0) {
      _ringSettings.percent =
          _counter.inSeconds / ClockSettings.focusDuration.inSeconds;
    } else {
      // in a break
      _ringSettings.percent =
          _counter.inSeconds / ClockSettings.breakDuration.inSeconds;
    }
    if (ClockSettings.repeat != 1) {
      // show repeat-text
      _ringSettings.title = "Pomodoro $_repeat";
    } else {
      _ringSettings.title = "";
    }
    _ringSettings.round = _status == 0 ? 'FOCUS' : 'BREAK';
    _ringSettings.time = fmt(_counter);
    setState(() {});
  }

  void _startStopTimer() {
    if (_counting) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
    }
    _counting = !_counting;
    setState(() {});
  }

  void _resetTimer() {
    _counting = false;
    _timer?.cancel();
    _counter = _status == 0
        ? ClockSettings.focusDuration
        : ClockSettings.breakDuration;
    _ringSettings
      ..percent = 0.0
      ..time = fmt(_counter);

    _updateRing();
  }

  void _doubleTapReset() {
    _counting = false;
    _timer?.cancel();
    _counter = ClockSettings.focusDuration;
    _status = 0;
    _repeat = 1;

    _updateRing();
  }

  bool _nextCounter() {
    var end = false;
    _status = _status == 0 ? 1 : 0;
    if (_status == 0) {
      _counter = ClockSettings.focusDuration;
      _repeat = _repeat + 1;
      if (_repeat > ClockSettings.repeat) {
        _repeat = 1;
        end = true;
      }
    } else {
      _counter = ClockSettings.breakDuration;
    }

    _updateRing();

    return end;
  }

  void _onCloseBottonPress() {
    windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    syncColorSettings();

    return Scaffold(
      backgroundColor: ClockSettings.theme.backgroundColor,
      body: Center(
          child: Column(
        children: [
          DraggableFormTitleBarWidget(
            title: Text(
              "Pomodoro",
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 2,
                  fontSize: ClockSettings.theme.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: ClockSettings.theme.titleColor),
            ),
            endWidget: IconButton(
                onPressed: _onCloseBottonPress,
                icon: Icon(
                  Icons.close,
                  color: ClockSettings.theme.titleColor,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onDoubleTap: _doubleTapReset,
                      child: IconButton(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh),
                        tooltip:
                            "Click to Reset round \n Double-Click to reset all",
                        color: ClockSettings.theme.buttonColor,
                      ),
                    ),
                    IconButton(
                      icon: _counting
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                      color: ClockSettings.theme.buttonColor,
                      // tooltip: _counting ? "Pause" : "Start",
                      onPressed: _startStopTimer,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      color: ClockSettings.theme.buttonColor,
                      // tooltip: _counting ? "Pause" : "Start",
                      onPressed: _nextCounter,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: ClockSettings.theme.buttonColor,
                      // tooltip: "Settings",
                      onPressed: () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return const ClockSettingWidget();
                        // }));
                        Navigator.pushNamed(context, 'clock_setting')
                            .then((_) => setState(() {}));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  @override
  void onWindowEvent(String eventName) {
    debugPrint('[WindowManager] onWindowEvent: $eventName');
  }
}
