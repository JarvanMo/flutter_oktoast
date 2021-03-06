library oktoast;

import 'dart:collection';

import 'package:flutter/material.dart';

LinkedHashMap<_OKToastState, BuildContext> _contextMap = LinkedHashMap();
const _defaultDuration = Duration(
  milliseconds: 2300,
);

const _opacityDuration = Duration(milliseconds: 250);

class OKToast extends StatefulWidget {
  final Widget child;

  final TextStyle textStyle;

  final Color backgroundColor;

  final double radius;

  final ToastPosition position;

  const OKToast({
    Key key,
    @required this.child,
    this.textStyle = const TextStyle(fontSize: 15.0),
    this.radius = 10.0,
    this.position = ToastPosition.center,
    Color backgroundColor,
  })  : this.backgroundColor = backgroundColor ?? const Color(0xDD000000),
        super(key: key);

  @override
  _OKToastState createState() => _OKToastState();
}

class _OKToastState extends State<OKToast> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _contextMap.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var overlay = Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (ctx) {
            _contextMap[this] = ctx;
            return widget.child;
          },
        ),
      ],
    );

    Widget w = Directionality(
      child: Stack(children: <Widget>[
        overlay,
        Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          bottom: 0.0,
          child: IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.0),
            ),
          ),
        )
      ]),
      textDirection: TextDirection.ltr,
    );

    return _ToastTheme(
      child: w,
      backgroundColor: widget.backgroundColor,
      radius: widget.radius,
      textStyle: widget.textStyle,
      position: widget.position,
    );
  }
}

void showToast(
  String msg, {
  BuildContext context,
  Duration duration = _defaultDuration,
  ToastPosition position,
  TextStyle textStyle,
  Color backgroundColor,
  double radius,
}) {
  context ??= _contextMap.values.first;

  textStyle ??= _ToastTheme.of(context).textStyle ?? TextStyle(fontSize: 15.0);
  position ??= _ToastTheme.of(context).position;
  backgroundColor ??= _ToastTheme.of(context).backgroundColor;
  radius ??= _ToastTheme.of(context).radius;

  Widget widget = Align(
    alignment: position.align,
    child: Container(
      margin: const EdgeInsets.all(50.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: ClipRect(
        child: Text(
          msg,
          style: textStyle,
        ),
      ),
    ),
  );

  showToastWidget(
    widget,
    context: context,
    duration: duration,
  );
}

void showToastWidget(
  Widget widget, {
  BuildContext context,
  Duration duration = _defaultDuration,
}) {
  context ??= _contextMap.values.first;
  var entry = OverlayEntry(builder: (ctx) {
    return IgnorePointer(
      child: _ToastContainer(
        duration: duration,
        child: widget,
      ),
    );
  });

  Future.delayed(duration, () {
    entry.remove();
  });

  Overlay.of(context).insert(entry);
}

class _ToastContainer extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const _ToastContainer({Key key, this.duration, this.child}) : super(key: key);

  @override
  __ToastContainerState createState() => __ToastContainerState();
}

class __ToastContainerState extends State<_ToastContainer> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 30), () {
      setState(() {
        opacity = 1.0;
      });
    });

    Future.delayed(widget.duration - _opacityDuration, () {
      setState(() {
        opacity = 0.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: _opacityDuration,
      child: widget.child,
      opacity: opacity,
    );
  }
}

class ToastPosition {
  final AlignmentGeometry align;
  final double offset;

  const ToastPosition({this.align = Alignment.center, this.offset = 0.0});

  static const center = const ToastPosition(align: Alignment.center, offset: 0.0);

  static const bottom = const ToastPosition(align: Alignment.bottomCenter, offset: -30.0);

  static const top = const ToastPosition(align: Alignment.topCenter, offset: 75.0);
}

class _ToastTheme extends InheritedWidget {
  final TextStyle textStyle;

  final Color backgroundColor;

  final double radius;

  final ToastPosition position;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  const _ToastTheme({
    this.textStyle,
    this.backgroundColor,
    this.radius,
    this.position,
    Widget child,
  }) : super(child: child);

  static _ToastTheme of(BuildContext context) => context.inheritFromWidgetOfExactType(_ToastTheme);
}
