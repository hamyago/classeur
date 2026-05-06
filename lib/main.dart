import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'App.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // French locale for timeago
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  runApp(const App());
}
