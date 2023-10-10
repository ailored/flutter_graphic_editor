import 'package:flutter/material.dart';

import '_instruments.dart';
import '_paint_mode.dart';

@immutable
class InstrumentData {
  final IconData? icon;
  final PaintMode? mode;
  final String? label;
  const InstrumentData({
    this.icon,
    this.mode,
    this.label,
  });
}

List<InstrumentData> instrumentLabel(Instruments instrument) => [
      InstrumentData(
          icon: Icons.edit, 
          mode: PaintMode.pencil, 
          label: instrument.drawing),
      InstrumentData(
          icon: Icons.horizontal_rule,
          mode: PaintMode.line,
          label: instrument.line),
      InstrumentData(
          icon: Icons.rectangle_outlined,
          mode: PaintMode.rect,
          label: instrument.rectangle),
      InstrumentData(
          icon: Icons.lens_outlined,
          mode: PaintMode.circle,
          label: instrument.circle),
      InstrumentData(
          icon: Icons.arrow_right_alt_outlined,
          mode: PaintMode.arrow,
          label: instrument.arrow),
      InstrumentData(
          icon: Icons.power_input,
          mode: PaintMode.dashLine,
          label: instrument.dashLine),
      InstrumentData(
          icon: Icons.text_format,
          mode: PaintMode.text,
          label: instrument.text),
    ];
