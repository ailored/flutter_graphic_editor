import 'package:flutter/material.dart';
import 'package:flutter_graphic_editor/src/view/pages/canvas_page.dart';
import 'package:flutter_graphic_editor/src/view/pages/filter_page.dart';
import 'package:flutter_graphic_editor/src/view/pages/image_page.dart';
import 'package:flutter_graphic_editor/src/view/pages/menu_page.dart';

void main(List<String> args) => runApp(const GraphicEditorApp());

class GraphicEditorApp extends StatelessWidget {
  const GraphicEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder> {
        '/drawonimage': (BuildContext context) => const DrawImgPage(imageData: null),
        '/drawcanvas': (BuildContext context) => const DrawingPage(title: 'PAINT'),
        '/filters': (BuildContext context) => const FiltersPage(imageData: ''),
      },
      home: const MainMenuPage(title: 'GRAPHIC REDACTOR'),
    );
  }
}
