import 'package:flutter/material.dart';

var theme = ThemeData(
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
  ),
  iconTheme: IconThemeData(),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    actionsIconTheme: IconThemeData(color: Colors.black54, size: 35),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 23),
  ),
  textTheme: TextTheme(
    bodyText2: TextStyle(color: Colors.black),
  ),
);
