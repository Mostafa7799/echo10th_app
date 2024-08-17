import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../../custom/box_decorations.dart';
import '../../my_theme.dart';
import '../../presenter/cart_counter.dart';
import '../../screens/cart.dart';

class CartIconButton extends StatefulWidget {
  const CartIconButton({super.key, required this.onPopped});
  final Function(dynamic) onPopped;

  @override
  State<CartIconButton> createState() => _CartIconButtonState();
}

class _CartIconButtonState extends State<CartIconButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Cart(has_bottomnav: false);
        })).then((value) {
          widget.onPopped(value);
        });
      },
      child: Container(
        decoration: BoxDecorations.buildCircularButtonDecoration_1(),
        width: 36,
        height: 36,
        padding: EdgeInsets.all(8),
        child: badges.Badge(
          badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.circle,
            badgeColor: MyTheme.accent_color,
            borderRadius: BorderRadius.circular(10),
          ),
          badgeAnimation: badges.BadgeAnimation.slide(
            toAnimate: true,
          ),
          stackFit: StackFit.loose,
          child: Image.asset(
            "assets/cart.png",
            color: MyTheme.dark_font_grey,
            height: 16,
          ),
          badgeContent: Consumer<CartCounter>(
            builder: (context, cart, child) {
              return Text(
                "${cart.cartCounter}",
                style: TextStyle(fontSize: 12, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
