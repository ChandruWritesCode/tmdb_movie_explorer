import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/pages/login_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  final apiManager = ApiCallManager();
  await settingsProvider.init();
  runApp(MyApp(settingsProvider: settingsProvider, apiCallManager: apiManager));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final ApiCallManager apiCallManager;
  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.apiCallManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ApiCallManager>.value(value: apiCallManager),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            useMaterial3: true,
            // colorSchemeSeed: const Color.fromRGBO(13, 37, 63, 1),
            colorSchemeSeed: const Color.fromRGBO(1, 180, 228, 1),
            scaffoldBackgroundColor: settings.darkMode
                ? Colors.black
                : Colors.white,
          ),
          home: context.read<SettingsProvider>().firstLogin
              ? LoginPage()
              : HomePage(),
        ),
      ),
    );
  }
}
