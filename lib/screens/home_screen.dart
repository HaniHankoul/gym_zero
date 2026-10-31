import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_zero/screens/home/home_body.dart';
import 'package:gym_zero/screens/payments/payments_screen.dart';
import 'package:gym_zero/shared/widgets/navigation/navigaiton_panel.dart';

import '../providers/navigation_provider.dart';
import '../shared/theme/app_theme.dart';
import 'members/members_screen.dart';
import 'reports/reports_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(navigationProvider);

    return Scaffold(
      backgroundColor: AppThemeDark.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NavigationPanel(),
                Expanded(child: _NavigationBody(section: section)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavigationBody extends StatelessWidget {
  final NavigationSection section;

  const _NavigationBody({required this.section});

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case NavigationSection.home:
        return const HomeBody();
      case NavigationSection.members:
        return const MembersScreen();
      case NavigationSection.subscriptions:
      case NavigationSection.payments:
        return PaymentsScreen();
      case NavigationSection.staff:
      case NavigationSection.reports:
        return ReportsScreen();
    }
  }
}
