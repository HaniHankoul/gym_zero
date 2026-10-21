import 'package:flutter/material.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';

import 'widgets/login_form_body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeDark.primaryBackground,
      body: SingleChildScrollView(child: Column(children: [LoginFormBody()])),
    );
  }
}
