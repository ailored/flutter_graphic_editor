import 'package:flutter/material.dart';
import 'package:flutter_graphic_editor/src/model/_instruments.dart';

class InputTextDialog extends StatelessWidget {
  const InputTextDialog(
      {Key? key,
      required this.controller,
      required this.fontSize,
      required this.onFinished,
      required this.color,
      required this.instruments})
      : super(key: key);
  final TextEditingController controller;
  final double fontSize;
  final VoidCallback onFinished;
  final Color color;
  final Instruments instruments;

  static void show(BuildContext context, TextEditingController controller,
      double fontSize, Color color, Instruments textDelegate,
      {required ValueChanged<BuildContext> onFinished}) {
    showDialog(
        context: context,
        builder: (context) {
          return InputTextDialog(
            controller: controller,
            fontSize: fontSize,
            onFinished: () => onFinished(context),
            color: color,
            instruments: textDelegate,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: onFinished,
              child: Text(
                instruments.done,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
