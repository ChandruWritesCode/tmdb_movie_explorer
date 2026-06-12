import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';
import 'package:tmdb_movie_explorer/providers/yt_trailer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  final apiManager = ApiCallManager();
  final ytlink = YtTrailer();
  final userData = UserData();
  await settingsProvider.init();
  await userData.init();
  runApp(
    MyApp(
      settingsProvider: settingsProvider,
      apiCallManager: apiManager,
      ytTrailer: ytlink,
      userData: userData,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final ApiCallManager apiCallManager;
  final YtTrailer ytTrailer;
  final UserData userData;
  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.apiCallManager,
    required this.ytTrailer,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ApiCallManager>.value(value: apiCallManager),
        ChangeNotifierProvider<YtTrailer>.value(value: ytTrailer),
        ChangeNotifierProvider<UserData>.value(value: userData),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            textTheme: GoogleFonts.interTextTheme(),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: GoogleFonts.interTextTheme().apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          // darkTheme: ThemeData(
          //   colorSchemeSeed: const Color.fromRGBO(13, 37, 63, 1),
          //   brightness: Brightness.dark,
          //   textTheme: GoogleFonts.manropeTextTheme().copyWith(
          //     bodyLarge: const TextStyle(color: Color(0xFFF5F5F5)),
          //     bodyMedium: const TextStyle(color: Color(0xFFE0E0E0)),
          //     titleLarge: const TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.w600,
          //     ),
          //     headlineMedium: const TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.w700,
          //     ),
          //   ),
          //   scaffoldBackgroundColor: settings.darkMode
          //       ? Colors.black
          //       : Colors.white,
          // ),
          // theme: ThemeData(
          //   textTheme: GoogleFonts.manropeTextTheme(
          //     ThemeData.dark().textTheme,
          //   ).apply(bodyColor: Colors.white, displayColor: Colors.white),
          //   brightness: settings.darkMode ? Brightness.dark : Brightness.light,
          //   useMaterial3: true,
          //   colorSchemeSeed: const Color.fromRGBO(13, 37, 63, 1),
          //   // colorSchemeSeed: const Color.fromRGBO(1, 180, 228, 1),
          //   scaffoldBackgroundColor: settings.darkMode
          //       ? Colors.black
          //       : Colors.white,
          // ),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(),
        ),
      ),
    );
  }
}
