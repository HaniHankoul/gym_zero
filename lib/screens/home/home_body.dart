import 'package:flutter/material.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';
import 'package:gym_zero/shared/widgets/custom_text.dart';

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
              CustomText(
                text: 'the last updates in this month',
                fontSize: 18,
                color: Colors.white70,
              ),
              const SizedBox(height: 40),
              _DashboardWrap(
                itemCount: 4,
                columnCount: columnCount,
                itemHeight: 140,
                children: const [
                  _DashboardMetric(
                    label: 'Active members',
                    value: '248',
                    detail: '+12 this month',
                    icon: Icons.groups_outlined,
                  ),
                  _DashboardMetric(
                    label: 'Monthly revenue',
                    value: '\$18,420',
                    detail: '+8.4% from last month',
                    icon: Icons.payments_outlined,
                  ),
                  _DashboardMetric(
                    label: 'Today\'s check-ins',
                    value: '86',
                    detail: '14 more than yesterday',
                    icon: Icons.how_to_reg_outlined,
                  ),
                  _DashboardMetric(
                    label: 'Memberships expiring',
                    value: '17',
                    detail: 'Within the next 30 days',
                    icon: Icons.event_busy_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _DashboardWrap(
                itemCount: 3,
                columnCount: 3,
                itemHeight: 242,
                flexes: const [2, 1, 0],
                children: const [
                  _DashboardPanel(
                    title: 'Recent activity',
                    icon: Icons.timeline_outlined,
                    child: _ActivityList(),
                  ),
                  _DashboardPanel(
                    title: 'Popular plans',
                    icon: Icons.star_outline,
                    child: _PlanList(),
                  ),
                  _DashboardPanel(
                    title: 'Quick note',
                    icon: Icons.sticky_note_2_outlined,
                    child: Text(
                      'Add a reminder for your team here.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
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
  final List<Widget> children;

  const _DashboardWrap({
    required this.itemCount,
    required this.columnCount,
    required this.itemHeight,
    required this.children,
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
                  child: children[index],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;

  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.greenAccent.shade100),
          ),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DashboardPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ActivityRow(name: 'Maria Santos', action: 'Checked in', time: '09:42'),
        _ActivityRow(
          name: 'Daniel Cruz',
          action: 'New membership',
          time: '09:15',
        ),
        _ActivityRow(
          name: 'Aisha Khan',
          action: 'Payment received',
          time: '08:57',
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String name;
  final String action;
  final String time;

  const _ActivityRow({
    required this.name,
    required this.action,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person_outline, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white)),
                Text(
                  action,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PlanRow(name: 'Premium', count: '112 members'),
        _PlanRow(name: 'Standard', count: '94 members'),
        _PlanRow(name: 'Day pass', count: '42 members'),
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String name;
  final String count;

  const _PlanRow({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white)),
          Text(
            count,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
