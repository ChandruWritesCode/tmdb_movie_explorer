import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/heroWidgets/all_heros.dart';
import 'package:tmdb_movie_explorer/pages/login_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(child: const UserHero()),
              ListTile(
                title: const Text("Toggle Mode"),
                onTap: () {
                  context.read<SettingsProvider>().toggleDarkMode();
                },
                // leading: Icon(
                //   context.watch<SettingsProvider>().darkMode
                //       ? Icons.dark_mode
                //       : Icons.light_mode,
                // ),
                trailing: SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.light_mode),
                      Switch(
                        activeTrackColor: Colors.white,
                        activeThumbColor: Theme.of(context).highlightColor,
                        value: context.watch<SettingsProvider>().darkMode,
                        onChanged: (_) {
                          context.read<SettingsProvider>().toggleDarkMode();
                        },
                      ),
                      const Icon(Icons.dark_mode),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: const ButtonStyle(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Alert"),
                        content: const Text("Do you really wanna log out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              );
                              WidgetsFlutterBinding.ensureInitialized();
                              context.read<SettingsProvider>().init();
                            },
                            child: const Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("No"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("Log out"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
