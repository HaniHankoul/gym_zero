import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_zero/providers/navigation_provider.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../constants/general_sizes.dart';

class NavigationElements extends ConsumerWidget {
  final String title;
  final List<List<dynamic>> icon;
  final String path;
  final NavigationSection section;

  const NavigationElements({
    required this.title,
    required this.icon,
    required this.path,
    required this.section,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSection = ref.watch(navigationProvider);
    final isSelected = selectedSection == section;

    return MaterialButton(
      height: 50,
      onPressed: () {
        ref.read(navigationProvider.notifier).select(section);
        context.go(path);
      },
      hoverElevation: 2,
      splashColor: Colors.grey,
      highlightColor: AppThemeDark.primaryLight,
      color: isSelected ? AppThemeDark.primaryLight : AppThemeDark.primary,
      elevation: 2,
      hoverColor: AppThemeDark.primaryLight,
      mouseCursor: SystemMouseCursors.click,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusS),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GeneralSizes.smallSize,
          vertical: 4,
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
