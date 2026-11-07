import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_zero/providers/navigation_provider.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../constants/general_sizes.dart';

class NavigationElements extends ConsumerWidget {
  final String title;
  final List<List<dynamic>> icon;
  final NavigationSection section;
  final bool isCompact;

  const NavigationElements({
    required this.title,
    required this.icon,
    required this.section,
    this.isCompact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSection = ref.watch(navigationProvider);
    final isSelected = selectedSection == section;

    return MaterialButton(
      height: 50,
      minWidth: isCompact ? 0 : null,
      padding: isCompact ? EdgeInsets.zero : null,
      onPressed: () {
        ref.read(navigationProvider.notifier).select(section);
      },
      hoverElevation: 2,
      splashColor: AppThemeDark.primary.withAlpha(100),
      highlightColor: AppThemeDark.primaryLight,
      color: isSelected ? AppThemeDark.primary : AppThemeDark.secondary,
      elevation: isSelected ? 3 : 0,
      hoverColor: AppThemeDark.primary.withAlpha(100),
      mouseCursor: SystemMouseCursors.click,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusS),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 0 : GeneralSizes.smallSize,
          vertical: 4,
        ),
        child: Row(
          mainAxisAlignment: isCompact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            HugeIcon(
              icon: icon,
              size: 18,
              color: isSelected ? Colors.black : Colors.white,
            ),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
