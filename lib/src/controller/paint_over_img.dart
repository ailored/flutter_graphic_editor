import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Image;

import 'package:flutter_graphic_editor/src/controller/draw_image.dart';
import 'package:flutter_graphic_editor/src/controller/painter.dart';
import 'package:flutter_graphic_editor/src/model/_instruments_data.dart';
import 'package:flutter_graphic_editor/src/model/_instruments.dart';
import 'package:flutter_graphic_editor/src/model/_paint_mode.dart';
import 'package:flutter_graphic_editor/src/model/_path_points.dart';
import 'package:flutter_graphic_editor/src/model/_controller.dart';
import 'package:flutter_graphic_editor/src/view/widgets/_color_widget.dart';
import 'package:flutter_graphic_editor/src/view/widgets/_mode_widget.dart';
import 'package:flutter_graphic_editor/src/view/widgets/_range_slider.dart';
import 'package:flutter_graphic_editor/src/view/widgets/_inputtext_dialog.dart';

@immutable
class ImagePainter extends StatefulWidget {
  const ImagePainter({
    Key? key,
    this.byteArray,
    this.isScalable,
    this.isCanvas = false,
    this.canvasBackgroundColor,
    this.initialPaintMode,
    this.initialStrokeWidth,
    this.initialColor,
  }) : super(key: key);

  factory ImagePainter.memory(
    Uint8List? byteArray, {
    required Key key,
    bool? scalable,
    PaintMode? initialPaintMode,
    double? initialStrokeWidth,
    Color? initialColor,
  }) {
    return ImagePainter(
      key: key,
      byteArray: byteArray,
      isScalable: scalable ?? false,
      initialPaintMode: initialPaintMode,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
    );
  }

  factory ImagePainter.canvas({
    required Key key,
    Color? canvasBgColor,
  }) {
    return ImagePainter(
      key: key,
      isCanvas: true,
      isScalable: false,
      canvasBackgroundColor: canvasBgColor ?? Colors.white,
    );
  }

  final Uint8List? byteArray;

  final bool? isScalable;
  final bool isCanvas;
  final Color? canvasBackgroundColor;

  final PaintMode? initialPaintMode;
  final double? initialStrokeWidth;
  final Color? initialColor;

  @override
  ImagePainterState createState() => ImagePainterState();
}

class ImagePainterState extends State<ImagePainter> {
  ui.Image? _image;
  bool _inDrag = false;
  Offset? _start, _end;
  int _strokeMultiplier = 1;

  late Instruments instruments;
  final _points = <Offset?>[];
  final _paintHistory = <PaintInfo>[];

  late final ValueNotifier<bool> _isLoaded;
  late final ValueNotifier<Controller> _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _isLoaded = ValueNotifier<bool>(false);
    _resolveAndConvertImage();
    _controller = ValueNotifier(
      const Controller().copyWith(
          mode: widget.initialPaintMode,
          strokeWidth: widget.initialStrokeWidth,
          color: widget.initialColor),
    );
    _textController = TextEditingController();
    instruments = Instruments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isLoaded.dispose();
    _textController.dispose();
    super.dispose();
  }

  Paint get _painter => Paint()
    ..color = _controller.value.color
    ..strokeWidth = _controller.value.strokeWidth * _strokeMultiplier
    ..style = _controller.value.mode == PaintMode.dashLine
        ? PaintingStyle.stroke
        : _controller.value.paintStyle;

  bool get isEdited => _paintHistory.isNotEmpty;

  //Converts the incoming image type from constructor to ui.Image
  Future<void> _resolveAndConvertImage() async {
    if (widget.byteArray != null) {
      _image = await _convertImage(widget.byteArray!);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided byteArray.");
      } else {
        _setStrokeMultiplier();
      }
    } else {
      _isLoaded.value = true;
    }
  }

  //avoid thin stroke on high res images.
  _setStrokeMultiplier() {
    if ((_image!.height + _image!.width) > 1000) {
      _strokeMultiplier = (_image!.height + _image!.width) ~/ 1000;
    }
  }

  //convert file image to ui.Image
  Future<ui.Image> _convertImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, (image) {
      _isLoaded.value = true;
      return completer.complete(image);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoaded,
      builder: (_, loaded, __) {
        if (loaded) {
          return widget.isCanvas ? _paintCanvas() : _paintImage();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _paintCanvas() {
    return Column(
      children: [
        _buildControls(),
        ClipRect(
          child: SizedBox(
            width: 450,
            height: 680,
            child: ValueListenableBuilder<Controller>(
              valueListenable: _controller,
              builder: (_, controller, __) {
                return PainterTransformer(
                  onInteractionStart: _paintStartGesture,
                  onInteractionUpdate: (details) =>
                      _paintUpdateGesture(details, controller),
                  onInteractionEnd: (details) =>
                      _paintEndGesture(details, controller),
                  child: CustomPaint(
                    willChange: true,
                    isComplex: true,
                    painter: DrawImage(
                      isCanvas: true,
                      backgroundColor: widget.canvasBackgroundColor,
                      points: _points,
                      paintHistory: _paintHistory,
                      isDragging: _inDrag,
                      update: UpdatePoints(
                        start: _start,
                        end: _end,
                        painter: _painter,
                        mode: controller.mode,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _paintImage() {
    return Column(
      children: [
        _buildControls(),
        Expanded(
          child: FittedBox(
            alignment: FractionalOffset.center,
            child: ClipRect(
              child: ValueListenableBuilder<Controller>(
                valueListenable: _controller,
                builder: (_, controller, __) {
                  return PainterTransformer(
                    maxScale: 3,
                    minScale: 1,
                    onInteractionUpdate: (details) =>
                        _paintUpdateGesture(details, controller),
                    onInteractionEnd: (details) =>
                        _paintEndGesture(details, controller),
                    child: CustomPaint(
                      size: Size(
                        _image!.width.toDouble(),
                        _image!.height.toDouble(),
                      ),
                      willChange: true,
                      isComplex: true,
                      painter: DrawImage(
                        image: _image,
                        points: _points,
                        paintHistory: _paintHistory,
                        isDragging: _inDrag,
                        update: UpdatePoints(
                          start: _start,
                          end: _end,
                          painter: _painter,
                          mode: controller.mode,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom)
      ],
    );
  }

  void _paintStartGesture(ScaleStartDetails onStart) {
    if (!widget.isCanvas) {
      setState(() {
        _start = onStart.focalPoint;
        _points.add(_start);
      });
    }
  }

  void _paintUpdateGesture(ScaleUpdateDetails onUpdate, Controller ctrl) {
    setState(
      () {
        _inDrag = true;
        _start ??= onUpdate.focalPoint;
        _end = onUpdate.focalPoint;
        if (ctrl.mode == PaintMode.pencil) _points.add(_end);
        if (ctrl.mode == PaintMode.text &&
            _paintHistory
                .where((element) => element.mode == PaintMode.text)
                .isNotEmpty) {
          _paintHistory
              .lastWhere((element) => element.mode == PaintMode.text)
              .offset = [_end];
        }
      },
    );
  }

  void _paintEndGesture(ScaleEndDetails onEnd, Controller controller) {
    setState(() {
      _inDrag = false;
      if (_start != null &&
          _end != null &&
          (controller.mode == PaintMode.pencil)) {
        _points.add(null);
        _addFreeStylePoints();
        _points.clear();
      } else if (_start != null &&
          _end != null &&
          controller.mode != PaintMode.text) {
        _addEndPoints();
      }
      _start = null;
      _end = null;
    });
  }

  void _addEndPoints() => _addPaintHistory(
        PaintInfo(
          offset: <Offset?>[_start, _end],
          painter: _painter,
          mode: _controller.value.mode,
        ),
      );

  void _addFreeStylePoints() => _addPaintHistory(
        PaintInfo(
          offset: <Offset?>[..._points],
          painter: _painter,
          mode: PaintMode.pencil,
        ),
      );

  PopupMenuItem _showOptionsRow(Controller controller) {
    return PopupMenuItem(
      enabled: false,
      child: Center(
        child: SizedBox(
          child: Wrap(
            children: instrumentLabel(instruments)
                .map(
                  (item) => SelectionItems(
                    data: item,
                    isSelected: controller.mode == item.mode,
                    onTap: () {
                      _controller.value = controller.copyWith(mode: item.mode);
                      Navigator.of(context).pop();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  PopupMenuItem _showRangeSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (_, ctrl, __) {
            return RangedSlider(
              value: ctrl.strokeWidth,
              onChanged: (value) =>
                  _controller.value = ctrl.copyWith(strokeWidth: value),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem _showColorPicker(Controller controller) {
    return PopupMenuItem(
      enabled: false,
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: (editorColors).map((color) {
            return ColorItem(
              isSelected: color == controller.color,
              color: color,
              onTap: () {
                _controller.value = controller.copyWith(color: color);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _addPaintHistory(PaintInfo info) {
    if (info.mode != PaintMode.none) {
      _paintHistory.add(info);
    }
  }

  void _openTextDialog() {
    _controller.value = _controller.value.copyWith(mode: PaintMode.text);
    final fontSize = 6 * _controller.value.strokeWidth;

    InputTextDialog.show(context, _textController, fontSize,
        _controller.value.color, instruments, onFinished: (context) {
      if (_textController.text != '') {
        setState(() => _addPaintHistory(
              PaintInfo(
                  mode: PaintMode.text,
                  text: _textController.text,
                  painter: _painter,
                  offset: []),
            ));
        _textController.clear();
      }
      Navigator.of(context).pop();
    });
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.grey[200],
      child: Row(
        children: [
          ValueListenableBuilder<Controller>(
            valueListenable: _controller,
            builder: (_, ctrl, __) {
              return PopupMenuButton(
                tooltip: instruments.changeMode,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                icon: Icon(
                    instrumentLabel(instruments)
                        .firstWhere((item) => item.mode == ctrl.mode)
                        .icon,
                    color: Colors.grey[700]),
                itemBuilder: (_) => [_showOptionsRow(ctrl)],
              );
            },
          ),
          ValueListenableBuilder<Controller>(
            valueListenable: _controller,
            builder: (_, controller, __) {
              return PopupMenuButton(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                tooltip: instruments.changeColor,
                icon: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                    color: controller.color,
                  ),
                ),
                itemBuilder: (_) => [_showColorPicker(controller)],
              );
            },
          ),
          PopupMenuButton(
            tooltip: instruments.changeBrushSize,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Icon(Icons.brush, color: Colors.grey[700]),
            itemBuilder: (_) => [_showRangeSlider()],
          ),
          IconButton(
              icon: const Icon(Icons.text_format), onPressed: _openTextDialog),
          const Spacer(),
          IconButton(
              tooltip: instruments.undo,
              icon: Icon(Icons.reply, color: Colors.grey[700]),
              onPressed: () {
                if (kDebugMode) print(_paintHistory.length);
                if (_paintHistory.isNotEmpty) {
                  setState(_paintHistory.removeLast);
                }
              }),
          IconButton(
            tooltip: instruments.clearAllProgress,
            icon: Icon(Icons.clear, color: Colors.grey[700]),
            onPressed: () => setState(_paintHistory.clear),
          ),
        ],
      ),
    );
  }
}
