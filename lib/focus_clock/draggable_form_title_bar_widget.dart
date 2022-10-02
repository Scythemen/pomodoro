import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DraggableFormTitleBarWidget extends StatefulWidget {
  const DraggableFormTitleBarWidget(
      {super.key, this.title, this.startWidget, this.endWidget});

  final Widget? title;
  final Widget? startWidget;
  final Widget? endWidget;

  @override
  State<StatefulWidget> createState() => _DraggableFormTitleBarWidget();
}

class _DraggableFormTitleBarWidget extends State<DraggableFormTitleBarWidget>
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: DragToMoveArea(
                  child: Container(
                      alignment: Alignment.center, child: widget.title)),
            ),
          ],
        ),
        if (widget.startWidget != null)
          Positioned(
              top: 0,
              left: 0,
              child: Container(
                child: widget.startWidget,
              )),
        if (widget.endWidget != null)
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                child: widget.endWidget,
              )),
      ],
    );

    // return Row(children: [
    //   if (widget.startWidget != null)
    //     Container(
    //       child: widget.startWidget,
    //     ),
    //   Expanded(
    //     child: DragToMoveArea(
    //         child: Container(alignment: Alignment.center, child: widget.title)),
    //   ),
    //   if (widget.endWidget != null)
    //     Stack(
    //       children: [
    //         Positioned(
    //             child: Container(
    //           child: widget.endWidget,
    //         ))
    //       ],
    //     ),
    // ]);
  }
}
