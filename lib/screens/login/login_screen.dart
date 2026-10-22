import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import 'widgets/login_form_body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeDark.primaryBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: isCompact
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FlutterLogo(size: 100),
                          const SizedBox(height: 24),
                          const LoginFormBody(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Center(child: FlutterLogo(size: 150)),
                          ),
                          const SizedBox(width: 40),
                          const Flexible(child: LoginFormBody()),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
