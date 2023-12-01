import 'package:flutter/material.dart';
import 'package:medicare/screens/doctor_detail.dart';
import 'package:medicare/screens/home.dart';
import 'package:medicare/tabs/home_page.dart';
import 'package:medicare/tabs/login_page.dart';
import 'package:medicare/tabs/signup_page.dart';

import '../screens/pills.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => LoginPage(),
  '/pills': (context) => PillsScreen(),
  '/homepage':(context) => HomePage(),
  '/login':(context) => LoginPage(),
  '/signup':(context) => SignupPage(),
};
