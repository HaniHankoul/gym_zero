import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_provider.dart';
import '../shared/constants/general_sizes.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/navigation/navigaiton_panel.dart';
import 'home/home_body.dart';
import 'home/widgets/login_content.dart';
import 'members/members_screen.dart';
import 'payments/payments_screen.dart';
import 'reports/reports_screen.dart';
import 'staff/staff_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(navigationProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemeDark.primaryBackground,

        title: Text(
          'GymZero',
          style: TextStyle(
            color: AppThemeDark.primary,
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),
        ),
      ),
      backgroundColor: AppThemeDark.primaryBackground,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const NavigationPanel(),
                verticalSpaceLarge(),
                LoginContent(),
              ],
            ),
            Expanded(child: _NavigationBody(section: section)),
          ],
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
        return const PaymentsScreen();
      case NavigationSection.staff:
        return const StaffScreen();
      case NavigationSection.reports:
        return const ReportsScreen();
    }
  }
}
