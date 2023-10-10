import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_graphic_editor/src/model/_filters_mode.dart';
import 'package:flutter_graphic_editor/src/view/pages/image_page.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, required this.imageData});
  final String imageData;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  final GlobalKey _globalKey = GlobalKey();
  final List<List<double>> _filters = [
    NO_FILTER,
    INVERT,
    SEPIA_MATRIX,
    GREYSCALE_MATRIX,
    VINTAGE_MATRIX,
    SWEET_MATRIX
  ];

  void _convertWidgetToImage() async {
    RenderRepaintBoundary? repaintBoundary = _globalKey
        .currentContext()!
        .findRenderObject() as RenderRepaintBoundary?;
    ui.Image boxImage = await repaintBoundary!.toImage(pixelRatio: 1);
    ByteData? byteData = await boxImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? uint8list = byteData!.buffer.asUint8List();
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawImgPage(imageData: uint8list),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Image image = Image.asset(
      widget.imageData,
      width: size.width,
      fit: BoxFit.cover,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filters",
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _convertWidgetToImage,
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: RepaintBoundary(
          key: _globalKey,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width,
              maxHeight: size.width,
            ),
            child: PageView.builder(
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.matrix(_filters[index]),
                    child: image,
                  );
                }),
          ),
        ),
      ),
    );
  }
}
