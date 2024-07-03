import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:workout_timer/pages/kreator_treninga.dart';
import 'package:workout_timer/pages/pocetna.dart';
import 'package:workout_timer/pages/pokreni_trening.dart';

import 'localization/locales.dart';


void main() {
  return runApp(
      MyApp()
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    configureLocalization();
    super.initState();
  }

  void configureLocalization(){
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');
    localization.onTranslatedLanguage = onTranslatedLanguage;
  }

  void onTranslatedLanguage(Locale? locale){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/' : (context) => Home(),
        '/creator' : (context) => TrainingCreator(),
        '/trening' : (context) => PokreniTrening()
      },
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
    );
  }
}
