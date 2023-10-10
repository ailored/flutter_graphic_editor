import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_graphic_editor/src/view/pages/filter_page.dart';
import 'package:flutter_graphic_editor/src/controller/paint_over_img.dart';

class DrawImgPage extends StatefulWidget {
  const DrawImgPage({super.key, required this.imageData});
  final Uint8List? imageData;

  @override
  State<DrawImgPage> createState() => _DrawImgPageState();
}

class _DrawImgPageState extends State<DrawImgPage> {
  final GlobalKey _imageKey = GlobalKey<ImagePainterState>();
  final ImagePicker _picker = ImagePicker();
  String? _retrieveDataError;
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRAPHIC REDACTOR')),
      body: Center(child: _imagePaint()),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: _onButtonPressedGetImage,
          heroTag: 'imageButton',
          tooltip: 'Pick Image from gallery',
          child: const Icon(Icons.photo),
        ),
      ),
    );
  }

  Widget _imagePaint() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) return retrieveError;
    if (widget.imageData != null) {
      return ImagePainter.memory(widget.imageData, key: _imageKey);
    } else {
      return Text(
        'SELECT IMAGE',
        style: Theme.of(context).textTheme.headline5,
      );
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _onButtonPressedGetImage() async {
    if (_imageFile != null) {
      _imageFile == null;
      _onButtonPressedGetImage();
    } else {
      XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FiltersPage(
            imageData: pickedFile!.path,
          ),
        ),
      );
      setState(() => _imageFile = pickedFile);
    }
  }
}
