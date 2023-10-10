import 'package:flutter/material.dart';

import '_paint_mode.dart';

@immutable
class Controller {
  final double strokeWidth;
  final Color color;
  final PaintingStyle paintStyle;
  final PaintMode mode;
  final String text;

  const Controller(
      {this.strokeWidth = 4.0,
      this.color = Colors.red,
      this.mode = PaintMode.pencil,
      this.paintStyle = PaintingStyle.stroke,
      this.text = ""});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Controller &&
        other.strokeWidth == strokeWidth &&
        other.color == color &&
        other.paintStyle == paintStyle &&
        other.mode == mode &&
        other.text == text;
  }

  @override
  int get hashCode {
    return strokeWidth.hashCode ^
        color.hashCode ^
        paintStyle.hashCode ^
        mode.hashCode ^
        text.hashCode;
  }

  Controller copyWith(
      {double? strokeWidth,
      Color? color,
      PaintMode? mode,
      PaintingStyle? paintingStyle,
      String? text}) {
    return Controller(
        strokeWidth: strokeWidth ?? this.strokeWidth,
        color: color ?? this.color,
        mode: mode ?? this.mode,
        paintStyle: paintingStyle ?? paintStyle,
        text: text ?? this.text);
  }
}
