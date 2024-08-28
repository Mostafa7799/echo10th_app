import 'dart:async';

import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/unRead_notification_counter.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/address.dart';
import 'package:active_ecommerce_flutter/screens/auction/auction_products.dart';
import 'package:active_ecommerce_flutter/screens/change_language.dart';
import 'package:active_ecommerce_flutter/screens/chat/messenger_list.dart';
import 'package:active_ecommerce_flutter/screens/classified_ads/my_classified_ads.dart';
import 'package:active_ecommerce_flutter/screens/club_point.dart';
import 'package:active_ecommerce_flutter/screens/currency_change.dart';
import 'package:active_ecommerce_flutter/screens/notification/notification_list.dart';
import 'package:active_ecommerce_flutter/screens/orders/order_list.dart';
import 'package:active_ecommerce_flutter/screens/profile_edit.dart';
import 'package:active_ecommerce_flutter/screens/refund_request.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:active_ecommerce_flutter/screens/wishlist.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:toast/toast.dart';

import '../repositories/auth_repository.dart';
import 'auction/auction_bidded_products.dart';
import 'auction/auction_purchase_history.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, this.show_back_button = false}) : super(key: key);

  final bool show_back_button;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ScrollController _mainScrollController = ScrollController();

  bool _auctionExpand = false;
  int? _cartCounter = 0;
  String _cartCounterString = "00";
  int? _wishlistCounter = 0;
  String _wishlistCounterString = "00";
  int? _orderCounter = 0;
  String _orderCounterString = "00";
  late BuildContext loadingcontext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  fetchAll() {
    fetchCounters();
    getNotificationCount();
  }

  getNotificationCount() async {
    Provider.of<UnReadNotificationCounter>(context, listen: false).getCount();
  }

  fetchCounters() async {
    var profileCountersResponse =
        await ProfileRepository().getProfileCountersResponse();

    _cartCounter = profileCountersResponse.cart_item_count;
    _wishlistCounter = profileCountersResponse.wishlist_item_count;
    _orderCounter = profileCountersResponse.order_count;

    _cartCounterString =
        counterText(_cartCounter.toString(), default_length: 2);
    _wishlistCounterString =
        counterText(_wishlistCounter.toString(), default_length: 2);
    _orderCounterString =
        counterText(_orderCounter.toString(), default_length: 2);

    setState(() {});
  }

  deleteAccountReq() async {
    loading();
    var response = await AuthRepository().getAccountDeleteResponse();

    if (response.result) {
      AuthHelper().clearUserData();
      Navigator.pop(loadingcontext);
      context.go("/");
    }
    ToastComponent.showDialog(response.message);
  }

  String counterText(String txt, {default_length = 3}) {
    var blank_zeros = default_length == 3 ? "000" : "00";
    var leading_zeros = "";
    if (default_length == 3 && txt.length == 1) {
      leading_zeros = "00";
    } else if (default_length == 3 && txt.length == 2) {
      leading_zeros = "0";
    } else if (default_length == 2 && txt.length == 1) {
      leading_zeros = "0";
    }

    var newtxt = (txt == "" || txt == null.toString()) ? blank_zeros : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leading_zeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  reset() {
    _cartCounter = 0;
    _cartCounterString = "00";
    _wishlistCounter = 0;
    _wishlistCounterString = "00";
    _orderCounter = 0;
    _orderCounterString = "00";
    setState(() {});
  }

  List<int> listItem = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  onTapLogout(BuildContext context) async {
    AuthHelper().clearUserData();
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: buildView(context),
    );
  }

  Widget buildView(context) {
    return Container(
      color: Colors.white,
      height: DeviceInfo(context).height,
      child: Stack(
        children: [
          Scaffold(
            appBar: buildCustomAppBar(context),
            body: buildBody(),
          ),
        ],
      ),
    );
  }

  RefreshIndicator buildBody() {
    return RefreshIndicator(
      color: MyTheme.accent_color,
      backgroundColor: Colors.red,
      onRefresh: _onPageRefresh,
      displacement: 10,
      child: buildBodyChildren(),
    );
  }

  CustomScrollView buildBodyChildren() {
    return CustomScrollView(
      controller: _mainScrollController,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: buildCountersRow(),
            ),
            Gutter(),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: buildHorizontalSettings(),
            ),
            Gutter(),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: buildSettingAndAddonsHorizontalMenu(),
            ),
          ]),
        )
      ],
    );
  }

  PreferredSize buildCustomAppBar(context) {
    return PreferredSize(
      preferredSize: Size(DeviceInfo(context).width!, 90),
      child: Container(
        // color: Colors.green,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: buildAppbarSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomVerticalCardList() {
    return Container(
      margin: EdgeInsets.only(bottom: 120, top: 14),
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
        children: [
          if (auction_addon_installed.$)
            Column(
              children: [
                Container(
                  height: _auctionExpand
                      ? is_logged_in.$
                          ? 140
                          : 75
                      : 40,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: InkWell(
                    onTap: () {
                      _auctionExpand = !_auctionExpand;
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              _auctionExpand
                                  ? Icons.keyboard_arrow_down
                                  : Icons.navigate_next_rounded,
                              size: 20,
                              color: MyTheme.dark_font_grey,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: _auctionExpand,
                          child: Container(
                            padding: const EdgeInsets.only(left: 40),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => OneContext().push(
                                    MaterialPageRoute(
                                      builder: (_) => AuctionProducts(),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '-',
                                        style: TextStyle(
                                          color: MyTheme.dark_font_grey,
                                        ),
                                      ),
                                      Text(
                                        " ${LangText(context).local.on_auction_products_ucf}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: MyTheme.dark_font_grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (is_logged_in.$)
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => OneContext().push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AuctionBiddedProducts(),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '-',
                                              style: TextStyle(
                                                color: MyTheme.dark_font_grey,
                                              ),
                                            ),
                                            Text(
                                              " ${LangText(context).local.bidded_products_ucf}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: MyTheme.dark_font_grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                        onTap: () => OneContext().push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AuctionPurchaseHistory(),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '-',
                                              style: TextStyle(
                                                color: MyTheme.dark_font_grey,
                                              ),
                                            ),
                                            Text(
                                              " ${LangText(context).local.purchase_history_ucf}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: MyTheme.dark_font_grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Ths section show after counter section
  // change Language, Edit Profile and Address section
  Widget buildHorizontalSettings() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildHorizontalSettingItem(true, "assets/language.png",
              AppLocalizations.of(context)!.language_ucf, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ChangeLanguage();
                },
              ),
            );
          }),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CurrencyChange();
              }));
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/currency.png",
                  height: 22,
                  width: 22,
                  color: MyTheme.black,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.currency_ucf,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              ],
            ),
          ),
          buildHorizontalSettingItem(
              is_logged_in.$,
              "assets/edit.png",
              AppLocalizations.of(context)!.edit_profile_ucf,
              is_logged_in.$
                  ? () {
                      AIZRoute.push(context, ProfileEdit()).then((value) {
                        //onPopped(value);
                      });
                    }
                  : () => showLoginWarning()),
          buildHorizontalSettingItem(
              is_logged_in.$,
              "assets/location.png",
              AppLocalizations.of(context)!.address_ucf,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Address();
                          },
                        ),
                      );
                    }
                  : () => showLoginWarning()),
        ],
      ),
    );
  }

  InkWell buildHorizontalSettingItem(
      bool isLogin, String img, String text, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            img,
            height: 25,
            width: 25,
            color: isLogin ? MyTheme.black : MyTheme.blue_grey,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isLogin ? MyTheme.black : MyTheme.blue_grey,
                ),
          )
        ],
      ),
    );
  }

  showLoginWarning() {
    return ToastComponent.showDialog(
        AppLocalizations.of(context)!.you_need_to_log_in,
        gravity: Toast.center,
        duration: Toast.lengthLong);
  }

  deleteWarningDialog() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                LangText(context).local.delete_account_warning_title,
                style: TextStyle(fontSize: 15, color: MyTheme.dark_font_grey),
              ),
              content: Text(
                LangText(context).local.delete_account_warning_description,
                style: TextStyle(fontSize: 13, color: MyTheme.dark_font_grey),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      pop(context);
                    },
                    child: Text(LangText(context).local.no_ucf)),
                TextButton(
                    onPressed: () {
                      pop(context);
                      deleteAccountReq();
                    },
                    child: Text(LangText(context).local.yes_ucf))
              ],
            ));
  }

  Widget buildSettingAndAddonsHorizontalMenu() {
    return SizedBox(
      width: DeviceInfo(context).width,
      height: 250,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView(
            scrollDirection: Axis.vertical,
            physics: const PageScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 5,
              crossAxisCount: 3,
            ),
            shrinkWrap: true,
            children: [
              if (wallet_system_status.$)
                buildSettingAndAddonsHorizontalMenuItem("assets/wallet.png",
                    AppLocalizations.of(context)!.my_wallet_ucf, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Wallet();
                  }));
                }),
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/orders.png",
                  AppLocalizations.of(context)!.orders_ucf,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return OrderList();
                          }));
                        }
                      : () => null),
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/heart.png",
                  AppLocalizations.of(context)!.my_wishlist_ucf,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Wishlist();
                          }));
                        }
                      : () => null),
              if (club_point_addon_installed.$)
                buildSettingAndAddonsHorizontalMenuItem(
                    "assets/points.png",
                    AppLocalizations.of(context)!.earned_points_ucf,
                    is_logged_in.$
                        ? () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Clubpoint();
                            }));
                          }
                        : () => null),
              Container(
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 12, end: 30),
                  badgeStyle: badges.BadgeStyle(
                    shape: badges.BadgeShape.circle,
                    badgeColor: MyTheme.accent_color,
                    borderRadius: BorderRadius.circular(10),
                    padding: EdgeInsets.all(5),
                  ),
                  badgeContent: Consumer<UnReadNotificationCounter>(
                    builder: (context, notification, child) {
                      return Text(
                        "${notification.unReadNotificationCounter}",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      );
                    },
                  ),
                  child: buildSettingAndAddonsHorizontalMenuItem(
                      "assets/notification.png",
                      AppLocalizations.of(context)!.notification_ucf,
                      is_logged_in.$
                          ? () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return NotificationList();
                              })).then((value) {
                                onPopped(value);
                              });
                            }
                          : () => null),
                ),
              ),
              if (refund_addon_installed.$)
                buildSettingAndAddonsHorizontalMenuItem(
                    "assets/refund.png",
                    AppLocalizations.of(context)!.refund_requests_ucf,
                    is_logged_in.$
                        ? () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return RefundRequest();
                            }));
                          }
                        : () => null),
              if (conversation_system_status.$)
                buildSettingAndAddonsHorizontalMenuItem(
                    "assets/messages.png",
                    AppLocalizations.of(context)!.messages_ucf,
                    is_logged_in.$
                        ? () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MessengerList();
                            }));
                          }
                        : () => null),
              if (classified_product_status.$)
                buildSettingAndAddonsHorizontalMenuItem(
                    "assets/classified_product.png",
                    AppLocalizations.of(context)!.classified_products,
                    is_logged_in.$
                        ? () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MyClassifiedAds();
                            }));
                          }
                        : () => null),

              // buildSettingAndAddonsHorizontalMenuItem(
              //     "assets/download.png",
              //     AppLocalizations.of(context)!.downloads_ucf,
              //     is_logged_in.$
              //         ? () {
              //             Navigator.push(context,
              //                 MaterialPageRoute(builder: (context) {
              //               return PurchasedDigitalProducts();
              //             }));
              //           }
              //         : () => null),
              // buildSettingAndAddonsHorizontalMenuItem(
              //     "assets/download.png",
              //     "Upload file",
              //     is_logged_in.$
              //         ? () {
              //             Navigator.push(context,
              //                 MaterialPageRoute(builder: (context) {
              //               return UploadFile();
              //             }));
              //           }
              //         : () => null),
              // notification and badge contents
            ],
          ),
        ),
      ),
    );
  }

  Container buildSettingAndAddonsHorizontalMenuItem(
      String img, String text, Function() onTap) {
    return Container(
      alignment: Alignment.center,
      child: InkWell(
        onTap: is_logged_in.$
            ? onTap
            : () {
                showLoginWarning();
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              img,
              width: 20,
              height: 20,
              color: is_logged_in.$ ? MyTheme.black : MyTheme.medium_grey_50,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color:
                        is_logged_in.$ ? MyTheme.black : MyTheme.medium_grey_50,
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCountersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCountersRowItem(
          _cartCounterString,
          AppLocalizations.of(context)!.in_your_cart_all_lower,
        ),
        buildCountersRowItem(
          _wishlistCounterString,
          AppLocalizations.of(context)!.in_your_wishlist_all_lower,
        ),
        buildCountersRowItem(
          _orderCounterString,
          AppLocalizations.of(context)!.your_ordered_all_lower,
        ),
      ],
    );
  }

  Widget buildCountersRowItem(String counter, String title) {
    return Card(
      margin: EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              counter,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              title,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppbarSection() {
    return Container(
      // color: Colors.amber,
      alignment: Alignment.center,
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: MyTheme.white, width: 1),
                //shape: BoxShape.rectangle,
              ),
              child: is_logged_in.$
                  ? ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.all(Radius.circular(100.0)),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: "${avatar_original.$}",
                        fit: BoxFit.fill,
                      ))
                  : Image.asset(
                      'assets/profile_placeholder.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
          buildUserInfo(),
          Spacer(),
          Container(
            width: 70,
            height: 30,
            child: Btn.basic(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              // 	rgb(50,205,50)
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: MyTheme.black)),
              child: Center(
                child: Text(
                  is_logged_in.$
                      ? AppLocalizations.of(context)!.logout_ucf
                      : LangText(context).local.login_ucf,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              onPressed: () {
                if (is_logged_in.$)
                  onTapLogout(context);
                else
                  context.push("/users/login");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserInfo() {
    return is_logged_in.$
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${user_name.$}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    //if user email is not available then check user phone if user phone is not available use empty string
                    "${user_email.$ != "" ? user_email.$ : user_phone.$ != "" ? user_phone.$ : ''}",
                  )),
            ],
          )
        : Text(
            LangText(context).local.login_or_reg,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context)!.please_wait_ucf}"),
            ],
          ));
        });
  }
}
