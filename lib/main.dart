import 'package:easy_localization/easy_localization.dart';
import 'package:fake_chat/generated/locale_keys.g.dart';
import 'package:fake_chat/route.dart';
import 'package:fake_chat/splash_screen.dart';
import 'package:fake_chat/view/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('ko'),
      Locale('en'),
    ],
    path: 'assets/translations',
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: LocaleKeys.splash_title.tr(),
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: MColors.naver_green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: Routers.generateRoute,
      home: SplashScreen(),
    );
  }
}
