import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmdb_movie_explorer/pages/home_page.dart';
import 'package:tmdb_movie_explorer/providers/basic_providers.dart';
import 'package:tmdb_movie_explorer/providers/tmdb_api_call.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController userNameCont = TextEditingController();
  LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.read<SettingsProvider>().toggleDarkMode();
            },
            icon: Icon(
              context.watch<SettingsProvider>().darkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              // Text("data"),
              const Spacer(),
              const LogoAnim(), const Spacer(),
              TextField(
                controller: userNameCont,
                decoration: InputDecoration(
                  focusColor: Theme.of(context).primaryColor,
                  hint: const Text('Your name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  context.read<ApiCallManager>().init();
                  context.read<SettingsProvider>().setUserName(
                    userNameCont.text,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => HomePage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).primaryColor,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).secondaryHeaderColor,
                  ),
                  minimumSize: const WidgetStatePropertyAll(
                    Size(double.infinity, 50),
                  ),
                ),
                child: const Text("Log in"),
              ),
              const SizedBox(height: 30),
              const Text(
                "By Logging in you agree to terms and conditions that doesn't exists",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoAnim extends StatelessWidget {
  const LogoAnim({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'login logo',
      child: Image.asset('assets/logos/primary_short.png'),
    );
  }
}
