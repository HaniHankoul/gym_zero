import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../shared/database/db_init.dart';
import 'members_provider.dart';
import 'payment_provider.dart';

class RecentActivityItem {
  final String name;
  final String action;
  final String time;

  const RecentActivityItem({
    required this.name,
    required this.action,
    required this.time,
  });
}

class PopularPlanItem {
  final String name;
  final int count;

  const PopularPlanItem({required this.name, required this.count});
}

class HomeDashboardData {
  final int activeMembers;
  final int totalMembers;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final int todayCheckIns;
  final int expiredMembersCount;
  final List<RecentActivityItem> recentActivity;
  final List<PopularPlanItem> popularPlans;

  const HomeDashboardData({
    required this.activeMembers,
    required this.totalMembers,
    required this.monthlyRevenue,
    required this.monthlyExpenses,
    required this.todayCheckIns,
    required this.expiredMembersCount,
    required this.recentActivity,
    required this.popularPlans,
  });
}

final quickNoteProvider = StateProvider<String>(
  (ref) => 'Add a reminder for your team here.',
);

final homeDashboardProvider = FutureProvider.autoDispose<HomeDashboardData>((
  ref,
) async {
  final members = await ref.watch(membersProvider.future);
  final paymentsState = await ref.watch(paymentsProvider.future);
  final db = await GymDatabase.instance.database;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayPrefix =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  int activeCount = 0;
  int expiredCount = 0;
  final planCounts = <String, int>{};

  for (final member in members) {
    final statusLower = member.status.toLowerCase();
    final expiry = DateTime.tryParse(member.expiryDate);
    final isDatePast = expiry != null && expiry.isBefore(today);

    if (statusLower == 'expired' || (statusLower == 'active' && isDatePast)) {
      expiredCount++;
    } else if (statusLower == 'active') {
      activeCount++;
      planCounts[member.membership] = (planCounts[member.membership] ?? 0) + 1;
    }
  }

  // Monthly revenue & expenses
  final monthlyRevenue = paymentsState.memberPayments
      .where((p) => p.date.year == now.year && p.date.month == now.month)
      .fold<double>(0.0, (sum, p) => sum + p.amount);

  final monthlyExpenses = paymentsState.gymExpenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold<double>(0.0, (sum, e) => sum + e.amount);

  // Today's check-ins
  final checkInRows = await db.rawQuery(
    'SELECT COUNT(*) AS count FROM attendance WHERE check_in_time LIKE ?',
    ['$todayPrefix%'],
  );
  final todayCheckIns = (checkInRows.first['count'] as int?) ?? 0;

  // Popular plans
  final popularPlans =
      planCounts.entries
          .map((e) => PopularPlanItem(name: e.key, count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

  // Recent activity
  final activityRows = await db.rawQuery('''
    SELECT m.name AS member_name, 'Checked in' AS action, a.check_in_time AS ts
    FROM attendance a
    JOIN members m ON a.member_id = m.member_id
    UNION ALL
    SELECT m.name AS member_name, 'New membership' AS action, sh.start_date AS ts
    FROM sub_history sh
    JOIN members m ON sh.member_id = m.member_id
    UNION ALL
    SELECT m.name AS member_name, 'Payment received' AS action, p.payment_date AS ts
    FROM payments p
    JOIN members m ON p.member_id = m.member_id
    ORDER BY ts DESC
    LIMIT 4
  ''');

  final recentActivity = activityRows.map((row) {
    final rawTs = (row['ts'] as String?) ?? '';
    final formattedTime = rawTs.contains('T')
        ? rawTs.split('T').last.substring(0, 5)
        : rawTs.contains(' ')
        ? rawTs.split(' ').last.substring(0, 5)
        : rawTs;

    return RecentActivityItem(
      name: (row['member_name'] as String?) ?? 'Member',
      action: (row['action'] as String?) ?? '',
      time: formattedTime,
    );
  }).toList();

  return HomeDashboardData(
    activeMembers: activeCount,
    totalMembers: members.length,
    monthlyRevenue: monthlyRevenue,
    monthlyExpenses: monthlyExpenses,
    todayCheckIns: todayCheckIns,
    expiredMembersCount: expiredCount,
    recentActivity: recentActivity,
    popularPlans: popularPlans.take(4).toList(),
  );
});
