import 'package:flutter/material.dart';
import 'package:gym_zero/shared/widgets/navigation/navigaiton_panel.dart';

import '../../shared/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeDark.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 950;
            return Row(children: [NavigationPanel()]);
          },
        ),
      ),
    );
  }
}
