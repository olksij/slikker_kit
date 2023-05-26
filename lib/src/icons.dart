import 'package:slikker_kit/slikker_kit.dart';

class SlikkerIcons {
  SlikkerIcons._();

  static const String _fontFamily = 'SlikkerIcons';
  static const String _fontPackage = 'slikker_kit';

  static const IconData plus =
      IconData(0xe900, fontFamily: _fontFamily, fontPackage: _fontPackage);
  static const IconData addTask =
      IconData(0xe902, fontFamily: _fontFamily, fontPackage: _fontPackage);
  static const IconData cloudUpload =
      IconData(0xe904, fontFamily: _fontFamily, fontPackage: _fontPackage);
  static const IconData trash =
      IconData(0xe906, fontFamily: _fontFamily, fontPackage: _fontPackage);
  static const IconData settings =
      IconData(0xe908, fontFamily: _fontFamily, fontPackage: _fontPackage);
  static const IconData search =
      IconData(0xe90A, fontFamily: _fontFamily, fontPackage: _fontPackage);
}

class IconExtended extends StatelessWidget {
  const IconExtended(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.backgroundColor,
    this.semanticLabel,
    this.textDirection,
  }) : super(key: key);

  /// The icon to display. The available icons are described in [Icons].
  ///
  /// The icon can be null, in which case the widget will render as an empty
  /// space of the specified [size].
  final IconData icon;

  /// The size of the icon in logical pixels.
  ///
  /// Icons occupy a square with width and height equal to size.
  ///
  /// Defaults to the current [IconTheme] size, if any. If there is no
  /// [IconTheme], or it does not specify an explicit size, then it defaults to
  /// 24.0.
  ///
  /// If this [Icon] is being placed inside an [IconButton], then use
  /// [IconButton.iconSize] instead, so that the [IconButton] can make the splash
  /// area the appropriate size as well. The [IconButton] uses an [IconTheme] to
  /// pass down the size to the [Icon].
  final double? size;

  /// The color to use when drawing the icon foreground.
  ///
  /// Defaults to the current [SLTheme.iconColor] icon color, if any.
  final Color? color;

  /// The color to use when drawing the icon background.
  ///
  /// If [backgroundColor] is unspecified, the color is calculated using [color]
  /// value.
  ///
  /// If both [color] and [backgroundColor] are unspecified,
  /// [SLTheme.iconColor] and [SLTheme.iconBackgeoundColor] are used.
  final Color? backgroundColor;

  /// Semantic label for the icon.
  ///
  /// Announced in accessibility modes (e.g TalkBack/VoiceOver).
  /// This label does not show in the UI.
  ///
  ///  * [SemanticsProperties.label], which is set to [semanticLabel] in the
  ///    underlying	 [Semantics] widget.
  final String? semanticLabel;

  /// The text direction to use for rendering the icon.
  ///
  /// If this is null, the ambient [Directionality] is used instead.
  ///
  /// Some icons follow the reading direction. For example, "back" buttons point
  /// left in left-to-right environments and right in right-to-left
  /// environments. Such icons have their [IconData.matchTextDirection] field
  /// set to true, and the [Icon] widget uses the [textDirection] to determine
  /// the orientation in which to draw the icon.
  ///
  /// This property has no effect if the [icon]'s [IconData.matchTextDirection]
  /// field is false, but for consistency a text direction value must always be
  /// specified, either directly using this property or using [Directionality].
  final TextDirection? textDirection;

  Icon _genIcon(IconData icon, Color? color) {
    return Icon(
      icon,
      color: color,
      semanticLabel: semanticLabel,
      size: size,
      textDirection: textDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData backgroundIcon = IconData(
      icon.codePoint + 1,
      fontFamily: icon.fontFamily,
      fontPackage: icon.fontPackage,
      matchTextDirection: icon.matchTextDirection,
    );

    return Stack(
      children: [
        _genIcon(backgroundIcon, backgroundColor),
        _genIcon(icon, color),
      ],
    );
  }
}
