import 'package:dashboard/provider/orders_provider.dart';
import 'package:dashboard/screens/dashboard/dashboard.dart';
import 'package:dashboard/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
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
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(),
        ),
      ],
      child: Consumer<ThemeModel>(builder: (_, themeModel, __) {
        return MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            textTheme: Typography().black.apply(fontFamily: 'OpenSans'),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            textTheme: Typography().white.apply(fontFamily: 'OpenSans'),
          ),
          themeMode: _getThemeMode(themeModel.themeMode),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt'),
          ],
          home: const DashboardScreen(),
        );
      }),
    );
  }
}
