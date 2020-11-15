import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ripple.dart';

class SlikkerCard extends StatefulWidget {
   /// The Hue which will be used for your card.
   final double accent; 

   /// If `true` *[DEFAULT]*, your widget gets shadows, pressing-like tap 
   /// feedback, and z-axis.
   final bool isFloating; 

   /// Decides how curved will be sides of your card. Default is 
   /// `BorderRadius.all(Radius.circular(12))`
   final BorderRadiusGeometry borderRadius; 

   /// The widget that is placed inside *SlikkerCard* widget
   final Widget child; 

   final EdgeInsetsGeometry padding; 

   /// The `Function` that will be invoked on user's tap.
   final Function onTap; 
   
   @override _SlikkerCardState createState() => _SlikkerCardState();

   static fun() {}

   SlikkerCard({ 
      this.accent = 240, 
      this.isFloating = true, 
      this.child = const Text('hey?'), 
      this.padding = const EdgeInsets.all(0), 
      this.onTap = fun, 
      this.borderRadius = const BorderRadius.all(Radius.circular(12)),
   });
}

class _SlikkerCardState extends State<SlikkerCard> with TickerProviderStateMixin{
   HSVColor color;
   AnimationController tapController;
   CurvedAnimation tapAnimation;

   @override void initState() {
      super.initState();
      color = HSVColor.fromAHSV(
         widget.isFloating ? 1 : 0.075, 
         widget.accent, 
         widget.isFloating ? 0.6 : 0.3, 
         widget.isFloating ? 1 : 0.75
      );

      tapController = AnimationController(
         vsync: this,
         duration: Duration(milliseconds: 150),
      );

      tapAnimation = CurvedAnimation(
         curve: Curves.easeOut,
         parent: tapController
      );
      
      tapAnimation.addListener(() => setState(() {}));
   }

   @override void dispose() {
      tapController.dispose();
      super.dispose();
   }

   @override Widget build(BuildContext context) {
      return Transform.translate(
         offset: Offset(0, widget.isFloating ? tapAnimation.value*3 : 0),
         child: Container( 
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
               borderRadius: widget.borderRadius,
               color: widget.isFloating ? Colors.white : color.toColor(),
               boxShadow: widget.isFloating ? [
                  BoxShadow (
                     color: color.withSaturation(0.6).withAlpha(0.12 + tapAnimation.value * -0.05).toColor(),
                     offset: Offset(0, 7 + tapAnimation.value * -2),
                     blurRadius: 40 + tapAnimation.value * -10,
                  ),
                  BoxShadow (
                     color: color.withSaturation(0.05 + tapAnimation.value * 0.01).toColor(),
                     offset: Offset(0,3),
                  ),
               ] : [],          
            ),
            child: Material(
               color: Colors.transparent,
               child: InkWell(
                  splashFactory: SlikkerRipple(),
                  splashColor: color.withAlpha(widget.isFloating ? 0.125 : 0.25)
                     .withValue(widget.isFloating ? 1 : 0.85)
                     .withSaturation(widget.isFloating ? 0.6 : 0.15)
                     .toColor(),
                  highlightColor: color.withAlpha(0.01).toColor(),
                  hoverColor: Colors.transparent,
                  onTapDown: (a) { 
                     HapticFeedback.lightImpact(); 
                     tapController.forward();
                  },
                  onTapCancel: () { 
                     tapController.reverse();
                  },
                  onTap: () { 
                     tapController.forward();
                     Future.delayed( Duration(milliseconds: 150), () => tapController.reverse(from: 1) ); 
                     Future.delayed( Duration(milliseconds: 100), () => widget.onTap()); 
                  },
                  child: Padding(
                     padding: widget.padding,
                     child: widget.child
                  )
               ),
            ),
         )
      );
   }
}