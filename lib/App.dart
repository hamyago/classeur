import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/user/controllers/home_controller.dart';
import 'features/user/controllers/request_controller.dart';
import 'features/provider/controllers/provider_controller.dart';
import 'shared/navigation/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => HomeController()),
          ChangeNotifierProvider(create: (_) => RequestController()),
          ChangeNotifierProvider(create: (_) => ProviderController()),
        ],
        child: Builder(
          builder: (ctx) {
            final authCtrl = ctx.read<AuthController>();
            final router = buildRouter(authCtrl);
            return MaterialApp.router(
              title: 'Auto-SOS',
              theme: AppTheme.light,
              debugShowCheckedModeBanner: false,
              routerConfig: router,
            );
          },
        ),
      );
}
