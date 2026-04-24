import 'app/app.dart';
import 'bootstrap/app_bootstrap.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapDoneDropApp();
  runApp(const DoneDropApp());
}
