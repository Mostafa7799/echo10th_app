import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/presenter/currency_presenter.dart';
import 'package:active_ecommerce_flutter/presenter/unRead_notification_counter.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'package:active_ecommerce_flutter/services/push_notification_service.dart';

import 'app_config.dart';
import 'firebase_options.dart';
import 'lang_config.dart';
import 'my_theme.dart';
import 'other_config.dart';
import 'utils/router_config.dart';

main() async {
  print("open");
  WidgetsFlutterBinding.ensureInitialized();

  FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    routes.routerDelegate.addListener(() {
      // print("objectobject");
    });

    /*bc = Widget Function(context,Container(),onGenerateRoute: (route){
      print("data ${route.name}");
      return MaterialPageRoute(builder:(context)=> Container());
    },onUnknownRoute: (route){
      print("data2 ${route.name}");
      return MaterialPageRoute(builder:(context)=> Container());
    },
      initialRoute: "/"
    );*/
    routes.routeInformationProvider.addListener(() {
      // print("123123");
    });
    super.initState();
    //print("Type of ${bc.runtimeType}");
    Future.delayed(Duration.zero).then(
      (value) async {
        Firebase.initializeApp().then((value) {
          if (OtherConfig.USE_PUSH_NOTIFICATION) {
            Future.delayed(Duration(milliseconds: 10), () async {
              PushNotificationService().initialise();
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (context) => CartCounter()),
          ChangeNotifierProvider(
              create: (context) => UnReadNotificationCounter()),
          ChangeNotifierProvider(create: (context) => CurrencyPresenter()),
        ],
        child: Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
          return MaterialApp.router(
            builder: (context, child) => OneContext().builder(
              context,
              child,
              // onGenerateRoute: (route) {
              //   return MaterialPageRoute(builder: (context2) {
              //     // OneContext().context = context2;
              //     return Scaffold(
              //       resizeToAvoidBottomInset: false,
              //       body: Builder(
              //         builder: (innerContext) {
              //           OneContext().context = innerContext;
              //           return child!;
              //         },
              //       ),
              //     );
              //   });
              // },
              // onUnknownRoute: (route) {
              //   // print("abc ${route.name}");
              //   return MaterialPageRoute(builder: (context) => child!);
              // },
            ),
            routerConfig: routes,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              scaffoldBackgroundColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: "PublicSansSerif",
              /*textTheme: TextTheme(
              bodyText1: TextStyle(),
              bodyText2: TextStyle(fontSize: 12.0),
            )*/
              //
              // the below code is getting fonts from http
              textTheme: MyTheme.textTheme1,
              // textTheme: TextTheme()
              fontFamilyFallback: ['NotoSans'],
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: LangConfig().supportedLocales(),
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (AppLocalizations.delegate.isSupported(deviceLocale!)) {
                return deviceLocale;
              }
              return const Locale('en');
            },
          );
        }));
  }
}
