import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import './button.dart';
import './theme.dart';

// TODO: [SlikkerTextField] extends [SlikkerButton].
// TODO: Remaster [SlikkerTextField] structure.

class SlikkerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final FocusNode focusNode;

  SlikkerTextField({
    required this.controller,
    Key? key,
    this.hintText = '',
    this.minLines,
    this.maxLines,
    this.padding,
    this.borderRadius,
    this.prefixWidget,
    this.suffixWidget,
  })  : focusNode = FocusNode(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = SlikkerTheme.of(context);

    final EditableText editableText = EditableText(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 17,
        color: theme.fontColor,
        fontFamily: theme.fontFamily,
        fontWeight: theme.fontWeight,
      ),
      cursorColor: theme.accentColor,
      backgroundCursorColor: theme.accentColor,
      maxLines: maxLines,
      minLines: minLines,
    );

    return SlikkerButton(
      disabled: true,
      borderRadius: borderRadius,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          prefixWidget ?? const SizedBox(),
          Expanded(child: editableText),
          suffixWidget ?? const SizedBox(),
        ],
      ),
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
