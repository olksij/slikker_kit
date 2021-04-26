import 'package:flutter/material.dart';
import 'get_color.dart';

class SlikkerTextField extends StatelessWidget {
  final TextEditingController? controller;
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

  const SlikkerTextField(
      {this.controller,
      this.hintText = '',
      this.accent = 240.0,
      this.minLines,
      this.maxLines,
      this.prefixIcon,
      this.padding = const EdgeInsets.all(15),
      this.isTransperent = false,
      this.prefixIconPadding,
      this.prefixIconSize = 24.0,
      this.borderRadius = const BorderRadius.all(Radius.circular(12.0))});

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: minLines,
      maxLines: maxLines,
      controller: controller,
      style: TextStyle(
          fontSize: 17, color: getColor(a: 1, h: accent, s: 0.4, v: 0.4)),
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
          color: getColor(a: 0.5, h: accent, s: 0.1, v: 0.7),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: isTransperent
            ? Colors.transparent
            : getColor(a: 0.8, h: accent, s: 0.04, v: 0.97),
      ),
    );
  }
}
