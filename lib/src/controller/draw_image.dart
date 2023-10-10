import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_graphic_editor/src/model/_paint_mode.dart';
import 'package:flutter_graphic_editor/src/model/_path_points.dart';

class DrawImage extends CustomPainter {
  final Image? image;
  final List<PaintInfo>? paintHistory;
  final UpdatePoints? update;
  final List<Offset?>? points;
  final bool isDragging;
  final bool isCanvas;
  final Color? backgroundColor;
  
  DrawImage(
      {this.image,
      this.update,
      this.points,
      this.isDragging = false,
      this.isCanvas = false,
      this.backgroundColor,
      this.paintHistory});

  @override
  void paint(Canvas canvas, Size size) {
    if (isCanvas) {
      canvas.drawRect(
          Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
          Paint()
            ..style = PaintingStyle.fill
            ..color = backgroundColor!);
    } else {
      paintImage(
        canvas: canvas,
        image: image!,
        filterQuality: FilterQuality.high,
        rect: Rect.fromPoints(
          const Offset(0, 0),
          Offset(size.width, size.height),
        ),
      );
    }
    showDrawResult(canvas, size);

    ///Draws line on the canvas while drawing
    showDrawProcess(canvas);
  }

  void showDrawResult(Canvas canvas, Size size) {
    for (var item in paintHistory!) {
      final offset = item.offset;
      final painter = item.painter;
      switch (item.mode) {
        case PaintMode.rect:
          canvas.drawRect(
              Rect.fromPoints(offset![0]!, offset[1]!), painter!);
          break;
        case PaintMode.line:
          canvas.drawLine(offset![0]!, offset[1]!, painter!);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(
            Rect.fromCircle(
                center: offset![1]!,
                radius: (offset[0]! - offset[1]!).distance),
          );
          canvas.drawPath(path, painter!);
          break;
        case PaintMode.arrow:
          _drawArrow(canvas, offset![0]!, offset[1]!, painter!);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(offset![0]!.dx, offset[0]!.dy)
            ..lineTo(offset[1]!.dx, offset[1]!.dy);
          canvas.drawPath(_drawDashLine(path, painter!.strokeWidth), painter);
          break;
        case PaintMode.pencil:
          for (var i = 0; i < offset!.length - 1; i++) {
            if (offset[i] != null && offset[i + 1] != null) {
              final path = Path()
                ..moveTo(offset[i]!.dx, offset[i]!.dy)
                ..lineTo(offset[i + 1]!.dx, offset[i + 1]!.dy);
              canvas.drawPath(path, painter!..strokeCap = StrokeCap.round);
            } else if (offset[i] != null && offset[i + 1] == null) {
              canvas.drawPoints(PointMode.points, [offset[i]!],
                  painter!..strokeCap = StrokeCap.round);
            }
          }
          break;
        case PaintMode.text:
          final textSpan = TextSpan(
            text: item.text,
            style: TextStyle(
                color: painter!.color,
                fontSize: 6 * painter.strokeWidth,
                fontWeight: FontWeight.bold),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(minWidth: 0, maxWidth: size.width);
          final textOffset = offset!.isEmpty
              ? Offset(size.width / 2 - textPainter.width / 2,
                  size.height / 2 - textPainter.height / 2)
              : Offset(offset[0]!.dx - textPainter.width / 2,
                  offset[0]!.dy - textPainter.height / 2);
          textPainter.paint(canvas, textOffset);
          break;
        default:
      }
    }
  }

  void showDrawProcess(Canvas canvas) {
    if (isDragging) {
      final start = update!.start;
      final end = update!.end;
      final painter = update!.painter;
      switch (update!.mode) {
        case PaintMode.rect:
          canvas.drawRect(Rect.fromPoints(start!, end!), painter!);
          break;
        case PaintMode.line:
          canvas.drawLine(start!, end!, painter!);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(Rect.fromCircle(
              center: end!, radius: (end - start!).distance));
          canvas.drawPath(path, painter!);
          break;
        case PaintMode.arrow:
          _drawArrow(canvas, start!, end!, painter!);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(start!.dx, start.dy)
            ..lineTo(end!.dx, end.dy);
          canvas.drawPath(_drawDashLine(path, painter!.strokeWidth), painter);
          break;
        case PaintMode.pencil:
          for (var i = 0; i < points!.length - 1; i++) {
            if (points![i] != null && points![i + 1] != null) {
              canvas.drawLine(
                  Offset(points![i]!.dx, points![i]!.dy),
                  Offset(points![i + 1]!.dx, points![i + 1]!.dy),
                  painter!..strokeCap = StrokeCap.round);
            } else if (points![i] != null && points![i + 1] == null) {
              canvas.drawPoints(PointMode.points,
                  [Offset(points![i]!.dx, points![i]!.dy)], painter!);
            }
          }
          break;
        default:
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint painter) {
    final arrowPainter = Paint()
      ..color = painter.color
      ..strokeWidth = painter.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, painter);
    final pathOffset = painter.strokeWidth / 15;
    var path = Path()
      ..lineTo(-15 * pathOffset, 10 * pathOffset)
      ..lineTo(-15 * pathOffset, -10 * pathOffset)
      ..close();
    canvas.save();
    canvas.translate(end.dx, end.dy);
    canvas.rotate((end - start).direction);
    canvas.drawPath(path, arrowPainter);
    canvas.restore();
  }

  Path _drawDashLine(Path path, double width) {
    final dashPath = Path();
    final dashWidth = 10.0 * width / 5;
    final dashSpace = 10.0 * width / 5;
    var distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(DrawImage oldDelegate) {
    return (oldDelegate.update != update ||
        oldDelegate.paintHistory!.length == paintHistory!.length);
  }
}

