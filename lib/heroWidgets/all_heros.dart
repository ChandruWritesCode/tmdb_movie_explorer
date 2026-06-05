import 'package:flutter/material.dart';

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

class UserHero extends StatelessWidget {
  const UserHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'UserLogo',
      child: Image.asset('assets/user/default_user.png'),
    );
  }
}
