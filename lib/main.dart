import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:slim/slim.dart';
import 'package:textme/view/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    SlimLocalizations.supportedLocales = [Locale('fr', 'FR')];

    /// If you want to customize you locale loader just create class that extends SlimLocaleLoader and change:
    ///
    //SlimLocalizations.slimLocaleLoader= YouCustomLocalLoader();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: SlimMaterialAppBuilder.builder,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      localizationsDelegates: SlimLocalizations.delegates,
      supportedLocales: SlimLocalizations.supportedLocales,
    );
  }
}
