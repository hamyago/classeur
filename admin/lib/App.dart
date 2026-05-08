import 'package:flutter/material.dart';
import 'core/constants/theme.dart';
import 'shared/router.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Auto-SOS Admin',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.dark,
        routerConfig: adminRouter,
      );
}
