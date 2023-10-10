import 'package:flutter/material.dart';
import '_paint_mode.dart';

class PaintInfo {
  PaintMode? mode;
  Paint? painter;
  List<Offset?>? offset;
  String? text;
  PaintInfo({this.offset, this.painter, this.text, this.mode});
}

@immutable
class UpdatePoints {
  final Offset? start;
  final Offset? end;
  final Paint? painter;
  final PaintMode? mode;

  const UpdatePoints({this.start, this.end, this.painter, this.mode});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdatePoints &&
        other.start == start &&
        other.end == end &&
        other.painter == painter &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    return start.hashCode ^ end.hashCode ^ painter.hashCode ^ mode.hashCode;
  }
}
