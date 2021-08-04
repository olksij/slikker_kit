import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import './button.dart';

// TODO: [SlikkerTextField] extends [SlikkerButton].
// TODO: Remaster [SlikkerTextField] structure.

class SlikkerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double accent;
  final int? minLines;
  final int? maxLines;
  final IconData? prefixIcon;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? prefixIconPadding;
  final double prefixIconSize;
  final bool isTransperent;
  final BorderRadius borderRadius;
  final FocusNode focusNode;

  SlikkerTextField({
    required this.controller,
    this.hintText = '',
    this.accent = 240.0,
    this.minLines,
    this.maxLines,
    this.prefixIcon,
    this.padding = const EdgeInsets.all(15),
    this.isTransperent = false,
    this.prefixIconPadding,
    this.prefixIconSize = 24.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
  }) : focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final EditableText editableText = EditableText(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 17,
        color: HSVColor.fromAHSV(1, accent, .4, .4).toColor(),
      ),
      cursorColor: HSVColor.fromAHSV(1, accent, .6, 1).toColor(),
      backgroundCursorColor: HSVColor.fromAHSV(.5, accent, .6, 1).toColor(),
      maxLines: maxLines,
      minLines: minLines,
    );

    return SlikkerButton(
      borderRadius: borderRadius,
      padding: padding,
      child: editableText,
    );

    /*TextField(
      minLines: minLines,
      maxLines: maxLines,
      controller: controller,
      style: TextStyle(
          fontSize: 17,
          color: HSVColor.fromAHSV(1, accent, 0.4, 0.4).toColor()),
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Container(
                padding: prefixIconPadding ?? padding,
                child: Icon(prefixIcon,
                    size: prefixIconSize, color: Color(0xFF3D3D66)),
              )
            : null,
        contentPadding: padding,
        border: new OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: borderRadius,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: HSVColor.fromAHSV(0.5, accent, 0.1, 0.7).toColor(),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: isTransperent
            ? Colors.transparent
            : HSVColor.fromAHSV(0.8, accent, 0.04, 0.97).toColor(),
      ),
    );*/
  }
}
