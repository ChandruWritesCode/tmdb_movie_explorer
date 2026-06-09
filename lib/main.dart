import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/pages/login_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';
import 'package:tmdb_movie_explorer/providers/yt_trailer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  final apiManager = ApiCallManager();
  final ytlink = YtTrailer();
  await settingsProvider.init();
  runApp(
    MyApp(
      settingsProvider: settingsProvider,
      apiCallManager: apiManager,
      ytTrailer: ytlink,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final ApiCallManager apiCallManager;
  final YtTrailer ytTrailer;
  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.apiCallManager,
    required this.ytTrailer,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ApiCallManager>.value(value: apiCallManager),
        ChangeNotifierProvider<YtTrailer>.value(value: ytTrailer),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.manropeTextTheme(
              ThemeData.dark().textTheme,
            ).apply(bodyColor: Colors.white, displayColor: Colors.white),
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            useMaterial3: true,
            colorSchemeSeed: const Color.fromRGBO(13, 37, 63, 1),
            // colorSchemeSeed: const Color.fromRGBO(1, 180, 228, 1),
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
