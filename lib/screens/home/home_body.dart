import 'package:flutter/material.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';

import '../../shared/constants/general_sizes.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final columnCount = isWide ? 4 : 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(GeneralSizes.largeSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The basic information dashboard for the application',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              _DashboardWrap(
                itemCount: 4,
                columnCount: columnCount,
                itemHeight: 140,
              ),
              const SizedBox(height: 32),
              _DashboardWrap(
                itemCount: 3,
                columnCount: 3,
                itemHeight: 242,
                flexes: const [2, 1, 0],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardWrap extends StatelessWidget {
  final int itemCount;
  final int columnCount;
  final double itemHeight;
  final List<int>? flexes;

  const _DashboardWrap({
    required this.itemCount,
    required this.columnCount,
    required this.itemHeight,
    this.flexes,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = GeneralSizes.largeSize;
        final itemWidth =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < itemCount; index++)
              SizedBox(
                width: flexes == null
                    ? itemWidth
                    : flexes![index] == 0
                    ? constraints.maxWidth
                    : constraints.maxWidth * flexes![index] / 3 - gap / 2,
                height: itemHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppThemeDark.primaryLight,
                    borderRadius: BorderRadius.circular(
                      GeneralSizes.borderRadiusS,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
