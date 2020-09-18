import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration _kUnconfirmedRippleDuration = Duration(seconds: 2);
const Duration _kFadeInDuration = Duration(milliseconds: 100);
const Duration _kRadiusDuration = Duration(milliseconds: 550);
const Duration _kFadeOutDuration = Duration(milliseconds: 475);
const Duration _kCancelDuration = Duration(milliseconds: 75);

RectCallback _getClipCallback(RenderBox referenceBox, bool containedInkWell, RectCallback rectCallback) {
	if (rectCallback != null) {
		assert(containedInkWell);
		return rectCallback;
	}
	if (containedInkWell)
		return () => Offset.zero & referenceBox.size;
	return null;
}

double _getTargetRadius(RenderBox referenceBox, bool containedInkWell, RectCallback rectCallback, Offset position) {
	final Size size = rectCallback != null ? rectCallback().size : referenceBox.size;
	final double d1 = size.bottomRight(Offset.zero).distance;
	final double d2 = (size.topRight(Offset.zero) - size.bottomLeft(Offset.zero)).distance;
	return math.max(d1, d2) / 2.0;
}

class SlikkerRipple extends InteractiveInkFeatureFactory {
	const SlikkerRipple();

	@override
	InteractiveInkFeature create({
		@required MaterialInkController controller,
		@required RenderBox referenceBox,
		@required Offset position,
		@required Color color,
		@required TextDirection textDirection,
		bool containedInkWell = false,
		RectCallback rectCallback,
		BorderRadius borderRadius,
		ShapeBorder customBorder,
		double radius,
		VoidCallback onRemoved,
	}) {
		return SlikkerRippleInk(
			controller: controller,
			referenceBox: referenceBox,
			position: position,
			color: color,
			containedInkWell: containedInkWell,
			rectCallback: rectCallback,
			borderRadius: borderRadius,
			customBorder: customBorder,
			radius: radius,
			onRemoved: onRemoved,
			textDirection: textDirection,
		);
	}
}

/// A visual reaction on a piece of [Material] to user input.
///
/// This class is used when the [Theme]'s [ThemeData.splashFactory] is [SlikkerRipple.splashFactory].
class SlikkerRippleInk extends InteractiveInkFeature {
	/// The [controller] argument is typically obtained via
	/// `Material.of(context)`.
	///
	/// If [containedInkWell] is true, then the ripple will be sized to fit
	/// the well rectangle, then clipped to it when drawn. The well
	/// rectangle is the box returned by [rectCallback], if provided, or
	/// otherwise is the bounds of the [referenceBox].
	///
	/// If [containedInkWell] is false, then [rectCallback] should be null.
	/// The ink ripple is clipped only to the edges of the [Material].
	/// This is the default.
	///
	/// When the ripple is removed, [onRemoved] will be called.
	SlikkerRippleInk({
		@required MaterialInkController controller,
		@required RenderBox referenceBox,
		@required Offset position,
		@required Color color,
		@required TextDirection textDirection,
		bool containedInkWell = false,
		RectCallback rectCallback,
		BorderRadius borderRadius,
		ShapeBorder customBorder,
		double radius,
		VoidCallback onRemoved,
	}) : assert(color != null),
      assert(position != null),
      assert(textDirection != null),
      _position = position,
      _borderRadius = borderRadius ?? BorderRadius.zero,
      _customBorder = customBorder,
      _textDirection = textDirection,
      _targetRadius = radius ?? _getTargetRadius(referenceBox, containedInkWell, rectCallback, position),
      _clipCallback = _getClipCallback(referenceBox, containedInkWell, rectCallback),
      super(controller: controller, referenceBox: referenceBox, color: color, onRemoved: onRemoved) {
		assert(_borderRadius != null);

		// Immediately begin fading-in the initial splash.
		_fadeInController = AnimationController(duration: _kFadeInDuration, vsync: controller.vsync)
			..addListener(controller.markNeedsPaint)
			..forward();


		// Controls the splash radius and its center. Starts upon confirm.
		_radiusController = AnimationController(duration: _kUnconfirmedRippleDuration, vsync: controller.vsync)
			..addListener(controller.markNeedsPaint)
			..forward();
		 // Initial splash diameter is 60% of the target diameter, final
		 // diameter is 10dps larger than the target diameter.
		_radius = _radiusController.drive(
			Tween<double>(
				begin: 0,
				end: _targetRadius * 2,
			).chain(_easeCurveTween),
		);

		// Controls the splash radius and its center. Starts upon confirm however its
		// Interval delays changes until the radius expansion has completed.
		_fadeOutController = AnimationController(duration: _kFadeOutDuration, vsync: controller.vsync)
			..addListener(controller.markNeedsPaint)
			..addStatusListener(_handleAlphaStatusChanged);

		controller.addInkFeature(this);
	}

	final Offset _position;
	final BorderRadius _borderRadius;
	final ShapeBorder _customBorder;
	final double _targetRadius;
	final RectCallback _clipCallback;
	final TextDirection _textDirection;

	Animation<double> _radius;
	AnimationController _radiusController;

	AnimationController _fadeInController;

	AnimationController _fadeOutController;

	/// Used to specify this type of ink splash for an [InkWell], [InkResponse]
	/// or material [Theme].
	static const InteractiveInkFeatureFactory splashFactory = SlikkerRipple();

	static final Animatable<double> _easeCurveTween = CurveTween(curve: Curves.easeOut);

	@override
	void confirm() {
		_radiusController
			..duration = _kRadiusDuration
			..forward();
		// This confirm may have been preceded by a cancel.
		_fadeInController.forward();
		_fadeOutController.animateTo(1.0, duration: _kFadeOutDuration);
	}

	@override
	void cancel() {
		_fadeInController.stop();
		// Watch out: setting _fadeOutController's value to 1.0 will
		// trigger a call to _handleAlphaStatusChanged() which will
		// dispose _fadeOutController.
		final double fadeOutValue = 1.0 - _fadeInController.value;
		_fadeOutController.value = fadeOutValue;
		if (fadeOutValue < 1.0)
			_fadeOutController.animateTo(1.0, duration: _kCancelDuration);
	}

	void _handleAlphaStatusChanged(AnimationStatus status) {
		if (status == AnimationStatus.completed)
			dispose();
	}

	@override
	void dispose() {
		_radiusController.dispose();
		_fadeInController.dispose();
		_fadeOutController.dispose();
		super.dispose();
	}

	@override
	void paintFeature(Canvas canvas, Matrix4 transform) {
		final int alpha = ((255-(_radius.value/(_targetRadius * 2.5) * 255))*(color.alpha/255)).round();
		final Paint paint = Paint()
			..color = color.withAlpha(alpha)
			..maskFilter = MaskFilter.blur(BlurStyle.normal, (_radius.value/3 + 20)/2 + 10)
			..strokeWidth = (_radius.value/3 + 50)/2 + 10
			..style = PaintingStyle.stroke;

		paintInkCircle(
			canvas: canvas,
			transform: transform,
			paint: paint,
			center: _position,
			textDirection: _textDirection,
			radius: _radius.value,
			customBorder: _customBorder,
			borderRadius: _borderRadius,
			clipCallback: _clipCallback,
		);
	}
}