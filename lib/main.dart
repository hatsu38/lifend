import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.setAppGroupId("group.lifend.homeWidget");
  runApp(const LifenedApp());
}
