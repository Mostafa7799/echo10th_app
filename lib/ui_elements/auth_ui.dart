import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';

class AuthScreen {
  static Widget buildScreen(
      BuildContext context, String headerText, Widget child) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              height: DeviceInfo(context).height! / 2,
              width: DeviceInfo(context).width,
              alignment: Alignment.topRight,
              decoration: BoxDecoration(
                color: MyTheme.accent_color,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.only(top: 48.0),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              width: 100,
                              height: 72,
                              decoration: BoxDecoration(
                                  color: MyTheme.black,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Image.asset(
                                'assets/app_logo.png',
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                        child: Text(
                          headerText,
                          style: TextStyle(
                              color: MyTheme.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration:
                              BoxDecorations.buildBoxDecoration_1(radius: 16),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
