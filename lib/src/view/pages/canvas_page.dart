import 'package:flutter/material.dart';
import 'package:flutter_graphic_editor/src/controller/paint_over_img.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key, required this.title});
  final String title;

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final _imageKey = GlobalKey<ImagePainterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImagePainter.canvas(
            key: _imageKey,
            canvasBgColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
