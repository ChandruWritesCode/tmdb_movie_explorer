import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/pages/login_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  runApp(MyApp(settingsProvider: settingsProvider));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => ApiCallManager()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            useMaterial3: true,
            // colorSchemeSeed: const Color.fromRGBO(13, 37, 63, 1),
            colorSchemeSeed: const Color.fromRGBO(1, 180, 228, 1),
          ),
          home: context.read<SettingsProvider>().firstLogin
              ? LoginPage()
              : HomePage(),
        ),
      ),
    );
  }
}
