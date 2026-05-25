import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/ble_provider.dart';
import 'providers/debug_provider.dart';
import 'providers/mail_provider.dart';
import 'screens/splash_screen.dart';

class SuperMiniApp extends StatelessWidget {
  const SuperMiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MailProvider()),
        ChangeNotifierProvider(create: (_) => DebugProvider()),
        ChangeNotifierProxyProvider2<MailProvider, DebugProvider, BleProvider>(
          create: (_) => BleProvider(),
          update: (_, mail, debug, ble) => (ble ?? BleProvider())..update(mail, debug),
        ),
      ],
      child: MaterialApp(
        title: 'SuperMini',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}