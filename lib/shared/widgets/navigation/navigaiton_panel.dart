import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../providers/navigation_provider.dart';
import '../../constants/general_sizes.dart';
import '../../theme/app_theme.dart';
import 'navigation_element.dart';

class NavigationItem {
  final String title;
  final List<List<dynamic>> icon;
  final String path;
  final NavigationSection section;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.path,
    required this.section,
  });
}

const navigationItems = [
  NavigationItem(
    title: 'Home',
    icon: HugeIcons.strokeRoundedHome01,
    path: '/',
    section: NavigationSection.home,
  ),
  NavigationItem(
    title: 'Members',
    icon: HugeIcons.strokeRoundedPersonStanding,
    path: '/members',
    section: NavigationSection.members,
  ),
  NavigationItem(
    title: 'Subscriptions',
    icon: HugeIcons.strokeRoundedSubscript,
    path: '/subscriptions',
    section: NavigationSection.subscriptions,
  ),
  NavigationItem(
    title: 'Payments',
    icon: HugeIcons.strokeRoundedReceipt,
    path: '/payments',
    section: NavigationSection.payments,
  ),
  NavigationItem(
    title: 'Staff',
    icon: HugeIcons.strokeRoundedGroup,
    path: '/staff',
    section: NavigationSection.staff,
  ),
  NavigationItem(
    title: 'Reports',
    icon: HugeIcons.strokeRoundedSchoolReportCard,
    path: '/reports',
    section: NavigationSection.reports,
  ),
];

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      width: isCompact ? 72 : 250,
      padding: EdgeInsets.all(GeneralSizes.largeSize),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
      ),
      child: Column(
        children: [
          for (final item in navigationItems) ...[
            NavigationElements(
              title: item.title,
              icon: item.icon,
              section: item.section,
              isCompact: isCompact,
            ),
            verticalSpaceLarge(),
          ],
        ],
      ),
    );
  }
}
