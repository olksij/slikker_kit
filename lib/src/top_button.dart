import 'package:flutter/material.dart';
import 'card.dart';
import 'accent_color.dart';

class TopButton extends StatefulWidget {       
   final String title; final IconData icon; 
   final double accent; final Function onTap; 
   final Function refreshFunction;

   TopButton({ this.title, this.icon, this.accent, this.onTap, this.refreshFunction });

   @override TopButtonState createState() => TopButtonState();
}

class TopButtonState extends State<TopButton> {
   int percent = 0; Color color;

   void refresh(p) { if (percent != p && this.mounted) setState(() => percent = p); }

   @override void initState() {
      super.initState();
      widget.refreshFunction(refresh);
      color = accentColor(1, widget.accent, 0.4, 0.2);
   }

   @override Widget build(BuildContext context) {
      return SlikkerCard(
         accent: 240,
         borderRadius: BorderRadius.circular(52),
         isFloating: false,
         onTap: this.widget.onTap,
         padding: EdgeInsets.fromLTRB(14, 13, 17, 14),
         child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               percent < 1 ? 
                  Icon(
                     widget.icon, 
                     color: color, 
                     size: 22,
                  ) : Padding(
                     padding: EdgeInsets.all(3),
                     child: SizedBox(
                        child: CircularProgressIndicator(
                           value: percent/100,
                           strokeWidth: 3,
                           valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                        height: 16,
                        width: 16,
                     ),
                  ),
               Container(width: 8, height: 24),
               Text(widget.title, style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 16
               ))
            ]
         ),
      );
   }
}