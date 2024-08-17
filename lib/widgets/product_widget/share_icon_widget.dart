import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_share/social_share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../custom/box_decorations.dart';
import '../../custom/btn.dart';
import '../../custom/lang_text.dart';
import '../../data_model/product_details_response.dart';
import '../../my_theme.dart';

class ShareIconWidget extends StatefulWidget {
  const ShareIconWidget({super.key, this.productDetails});
  final DetailedProduct? productDetails;

  @override
  State<ShareIconWidget> createState() => _ShareIconWidgetState();
}

class _ShareIconWidgetState extends State<ShareIconWidget> {
  bool _showCopied = false;
  onCopyTap(setState) {
    setState(() {
      _showCopied = true;
    });
    Timer(Duration(seconds: 3), () {
      setState(() {
        _showCopied = false;
      });
    });
  }

  onPressShare(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Btn.minWidthFixHeight(
                      minWidth: 75,
                      height: 26,
                      color: MyTheme.accent_color,
                      child: Text(
                        AppLocalizations.of(context)!.copy_product_link_ucf,
                        style: TextStyle(
                          color: MyTheme.white,
                        ),
                      ),
                      onPressed: () {
                        onCopyTap(setState);
                        Clipboard.setData(ClipboardData(
                            text: widget.productDetails!.link ?? ""));
                      },
                    ),
                    _showCopied
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              AppLocalizations.of(context)!.copied_ucf,
                              style: TextStyle(
                                  color: MyTheme.medium_grey, fontSize: 12),
                            ),
                          )
                        : Container(),
                    Btn.minWidthFixHeight(
                      minWidth: 75,
                      height: 26,
                      color: MyTheme.accent_color,
                      child: Text(
                        AppLocalizations.of(context)!.share_options_ucf,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        SocialShare.shareOptions(widget.productDetails!.link!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Btn.minWidthFixHeight(
                      minWidth: 75,
                      height: 30,
                      child: Text(
                        LangText(context).local.close_all_capital,
                        style: TextStyle(
                          color: MyTheme.font_grey,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressShare(context);
      },
      child: Container(
        decoration: BoxDecorations.buildCircularButtonDecoration_1(),
        width: 36,
        height: 36,
        child: Center(
          child: Icon(
            Icons.share_outlined,
            color: MyTheme.dark_font_grey,
            size: 16,
          ),
        ),
      ),
    );
  }
}
