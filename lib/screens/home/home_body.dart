import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';
import 'package:gym_zero/shared/widgets/custom_text.dart';

import '../../providers/home_provider.dart';
import '../../shared/constants/general_sizes.dart';

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final quickNote = ref.watch(quickNoteProvider);

    return Container(
      color: AppThemeDark.primaryBackground,
      child: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomText(
              text: 'Failed to load dashboard: $err',
              color: AppThemeDark.error,
            ),
          ),
        ),
        data: (data) {
          final netThisMonth = data.monthlyRevenue - data.monthlyExpenses;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              final isMedium = constraints.maxWidth >= 850;
              final metricColumns = isWide
                  ? 4
                  : isMedium
                  ? 3
                  : 2;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(GeneralSizes.largeSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppThemeDark.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Overview of your gym performance and member activity this month.',
                      style: TextStyle(color: AppThemeDark.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Top KPI Metric Cards
                    _MetricGrid(
                      columnCount: metricColumns,
                      maxWidth: constraints.maxWidth,
                      children: [
                        _MetricCard(
                          label: 'Active Members',
                          value: '${data.activeMembers}',
                          detail: '${data.totalMembers} total registered',
                          icon: Icons.groups_outlined,
                          accentColor: AppThemeDark.primary,
                        ),
                        _MetricCard(
                          label: 'Monthly Revenue',
                          value: '\$${data.monthlyRevenue.toStringAsFixed(2)}',
                          detail:
                              'Net: ${netThisMonth >= 0 ? '+' : '-'}\$${netThisMonth.abs().toStringAsFixed(2)}',
                          icon: Icons.payments_outlined,
                          accentColor: AppThemeDark.success,
                        ),
                        _MetricCard(
                          label: 'Today\'s Check-ins',
                          value: '${data.todayCheckIns}',
                          detail: 'Checked in today',
                          icon: Icons.how_to_reg_outlined,
                          accentColor: AppThemeDark.info,
                        ),
                        _MetricCard(
                          label: 'Expired Memberships',
                          value: '${data.expiredMembersCount}',
                          detail: data.expiredMembersCount == 0
                              ? 'All memberships up to date'
                              : 'Requires renewal',
                          icon: Icons.event_busy_outlined,
                          accentColor: AppThemeDark.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Middle Section: Recent Activity & Popular Plans
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _SectionCard(
                              title: 'Recent Activity',
                              subtitle: 'Latest member actions & payments',
                              icon: Icons.timeline_outlined,
                              child: _ActivityViewer(
                                activities: data.recentActivity,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _SectionCard(
                              title: 'Popular Plans',
                              subtitle: 'Active subscriptions breakdown',
                              icon: Icons.workspace_premium_outlined,
                              child: _PopularPlansViewer(
                                plans: data.popularPlans,
                                totalActive: data.activeMembers,
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _SectionCard(
                        title: 'Recent Activity',
                        subtitle: 'Latest member actions & payments',
                        icon: Icons.timeline_outlined,
                        child: _ActivityViewer(activities: data.recentActivity),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Popular Plans',
                        subtitle: 'Active subscriptions breakdown',
                        icon: Icons.workspace_premium_outlined,
                        child: _PopularPlansViewer(
                          plans: data.popularPlans,
                          totalActive: data.activeMembers,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Bottom Section: Team Quick Note
                    _SectionCard(
                      title: 'Team Quick Note',
                      subtitle: 'Shared reminder for reception and trainers',
                      icon: Icons.sticky_note_2_outlined,
                      trailing: OutlinedButton.icon(
                        onPressed: () =>
                            _editQuickNote(context, ref, quickNote),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit note'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppThemeDark.textWhite,
                          side: const BorderSide(
                            color: AppThemeDark.borderPrimary,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppThemeDark.primaryBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppThemeDark.borderPrimary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        child: Text(
                          quickNote,
                          style: const TextStyle(
                            color: AppThemeDark.textWhite,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editQuickNote(
    BuildContext context,
    WidgetRef ref,
    String currentNote,
  ) async {
    final controller = TextEditingController(text: currentNote);
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeDark.secondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppThemeDark.borderPrimary),
        ),
        title: const Text(
          'Edit Quick Note',
          style: TextStyle(
            color: AppThemeDark.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            style: const TextStyle(color: AppThemeDark.textWhite),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppThemeDark.primaryBackground,
              hintText: 'Write a reminder for your team...',
              hintStyle: const TextStyle(color: AppThemeDark.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppThemeDark.borderPrimary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemeDark.primary, width: 2),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppThemeDark.primary),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeDark.primary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    controller.dispose();

    if (updated != null && updated.isNotEmpty) {
      ref.read(quickNoteProvider.notifier).state = updated;
    }
  }
}

class _MetricGrid extends StatelessWidget {
  final int columnCount;
  final double maxWidth;
  final List<Widget> children;

  const _MetricGrid({
    required this.columnCount,
    required this.maxWidth,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 16.0;
    final itemWidth = (maxWidth - 50 * (columnCount - 1)) / columnCount;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final child in children) SizedBox(width: itemWidth, child: child),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accentColor.withValues(alpha: 0.14),
            foregroundColor: accentColor,
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeDark.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppThemeDark.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppThemeDark.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppThemeDark.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ActivityViewer extends StatelessWidget {
  final List<RecentActivityItem> activities;

  const _ActivityViewer({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'No recent activity recorded yet.',
            style: TextStyle(color: AppThemeDark.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (_, _) => Divider(
        color: AppThemeDark.borderPrimary.withValues(alpha: 0.5),
        height: 16,
      ),
      itemBuilder: (context, index) {
        final item = activities[index];
        final isPayment = item.action.toLowerCase().contains('payment');
        final isCheckIn = item.action.toLowerCase().contains('check');

        final badgeColor = isPayment
            ? AppThemeDark.success
            : isCheckIn
            ? AppThemeDark.info
            : AppThemeDark.primary;

        final badgeIcon = isPayment
            ? Icons.attach_money
            : isCheckIn
            ? Icons.how_to_reg_outlined
            : Icons.card_membership_outlined;

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: badgeColor.withValues(alpha: 0.14),
              child: Icon(badgeIcon, color: badgeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppThemeDark.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.action,
                    style: const TextStyle(
                      color: AppThemeDark.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppThemeDark.primaryBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppThemeDark.borderPrimary),
              ),
              child: Text(
                item.time,
                style: const TextStyle(
                  color: AppThemeDark.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PopularPlansViewer extends StatelessWidget {
  final List<PopularPlanItem> plans;
  final int totalActive;

  const _PopularPlansViewer({required this.plans, required this.totalActive});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'No active plans yet.',
            style: TextStyle(color: AppThemeDark.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < plans.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _PlanProgressItem(
            name: plans[i].name,
            count: plans[i].count,
            ratio: totalActive > 0 ? plans[i].count / totalActive : 0.0,
          ),
        ],
      ],
    );
  }
}

class _PlanProgressItem extends StatelessWidget {
  final String name;
  final int count;
  final double ratio;

  const _PlanProgressItem({
    required this.name,
    required this.count,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppThemeDark.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count ${count == 1 ? 'member' : 'members'}',
              style: const TextStyle(
                color: AppThemeDark.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: AppThemeDark.primaryBackground,
            valueColor: AlwaysStoppedAnimation<Color>(AppThemeDark.primary),
          ),
        ),
      ],
    );
  }
}
