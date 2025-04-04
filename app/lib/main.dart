import 'dart:io';

import 'package:dashboard/api/api.dart';
import 'package:dashboard/provider/orders_provider.dart';
import 'package:dashboard/screens/dashboard/dashboard.dart';
import 'package:dashboard/screens/machine/machine.dart';
import 'package:dashboard/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadApiUrl();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: "Shop Dashboard",
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

ThemeMode _getThemeMode(ThemeModeType mode) {
  switch (mode) {
    case ThemeModeType.light:
      return ThemeMode.light;
    case ThemeModeType.dark:
      return ThemeMode.dark;
    case ThemeModeType.system:
      return ThemeMode.system;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider<ThemeModel>(create: (_) => ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (_, themeModel, __) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              textTheme: Typography().black.apply(
                fontFamily: GoogleFonts.openSans().fontFamily,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              textTheme: Typography().white.apply(
                fontFamily: GoogleFonts.openSans().fontFamily,
              ),
            ),
            themeMode: _getThemeMode(themeModel.themeMode),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt')],
            home:
                apiUrl == null
                    ? const MachineScreen()
                    : const DashboardScreen(),
          );
        },
      ),
    );
  }
}
