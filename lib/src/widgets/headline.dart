import 'package:flutter/material.dart';

const Duration headlineAnimationDuration = const Duration(milliseconds: 400);
const List<Color> headlineTextColors = [Colors.blue, Colors.deepOrange];

class HeadLine extends ImplicitlyAnimatedWidget {
  final String text;
  final int index;

  Color get targetColor => headlineTextColors[index];

  const HeadLine({Key key, this.text, this.index})
      : super(key: key, duration: headlineAnimationDuration);

  @override
  _HeadLineState createState() => _HeadLineState();
}

class _HeadLineState extends AnimatedWidgetBaseState<HeadLine> {
  _GhostFaceTween _colorTween;
  _SwitchStringTween _switchStringTween;

  @override
  Widget build(BuildContext context) {
    var evaluate = _colorTween.evaluate(animation);

    var evaluateText = _switchStringTween.evaluate(animation);

    return Text(
      "$evaluateText",
      style: TextStyle(color: evaluate),
    );
  }

  void forEachTween(visitor) {
    _colorTween = visitor(_colorTween, widget.targetColor,
        (color) => _GhostFaceTween(begin: color));

    _switchStringTween = visitor(_switchStringTween, widget.text,
        (value) => _SwitchStringTween(begin: value));
  }
}

class _GhostFaceTween extends Tween<Color> {
  final Color middle = Colors.white;

  _GhostFaceTween({Color begin, Color end}) : super(begin: begin, end: end);

  Color lerp(double t) {
    if (t < 0.5) {
      return Color.lerp(begin, middle, t * 0.5);
    } else {
      return Color.lerp(middle, end, (t - 0.5) * 2);
    }
  }
}

class _SwitchStringTween extends Tween<String> {
  _SwitchStringTween({String begin, String end})
      : super(begin: begin, end: end);

  String lerp(double t) {
    if (t < 0.5) {
      return begin;
    }
    return end;
  }
}
