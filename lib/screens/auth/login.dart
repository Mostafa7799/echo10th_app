import 'dart:developer';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/password_forget.dart';
import 'package:active_ecommerce_flutter/screens/auth/registration.dart';

import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';

import 'package:toast/toast.dart';

import '../../custom/loading.dart';
import '../../repositories/address_repository.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";

  //controllers
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {
    FocusScope.of(context).unfocus();

    Loading.show(context);
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    log('Email $email' + '  Password $password');

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var loginResponse = await AuthRepository().getLoginResponse(
        _login_by == 'email' ? email : _phone, password, _login_by);
    Loading.close();
// empty temp user id after logged in
    temp_user_id.$ = "";
    temp_user_id.save();

    if (loginResponse.result == false) {
      if (loginResponse.message.runtimeType == List) {
        ToastComponent.showDialog(loginResponse.message!.join("\n"),
            gravity: Toast.center, duration: 3);
        return;
      }
      ToastComponent.showDialog(loginResponse.message!.toString(),
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(loginResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
      AuthHelper().setUserData(loginResponse);
      // push notification starts
      context.push("/");
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;

        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String? fcmToken = await _fcm.getToken();

        if (fcmToken != null) {
          print("--fcm token--");
          if (is_logged_in.$ == true) {
            // update device token
            await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.login_to} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.email_ucf,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: MyTheme.accent_color),
                ),
              ),
              TextField(
                controller: _emailController,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(),
              ),
              Gutter(),
              Text(AppLocalizations.of(context)!.password_ucf,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: MyTheme.accent_color)),
              TextField(
                controller: _passwordController,
                autofocus: false,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecorations.buildInputDecoration_1(),
              ),
              GutterSmall(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PasswordForget();
                      }));
                    },
                    child: Text(
                      AppLocalizations.of(context)!
                          .login_screen_forgot_password,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              GutterLarge(),
              Btn.minWidthFixHeight(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                child: Text(
                  AppLocalizations.of(context)!.login_screen_log_in,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                onPressed: () {
                  onPressedLogin();
                },
              ),
              GutterTiny(),
              Btn.minWidthFixHeight(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: MyTheme.amber_medium,
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                child: Text(
                  AppLocalizations.of(context)!.login_screen_sign_up,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: MyTheme.accent_color),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Registration();
                  }));
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
