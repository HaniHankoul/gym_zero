import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../shared/database/db_init.dart'; // Adjust path if needed

enum ReportType { membership, payments, revenue }

class ReportRecord {
  final int id;
  final String name;
  final ReportType type;
  final DateTime createdAt;
  final String period;
  final String format;
  final String status;

  const ReportRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.period,
    required this.format,
    required this.status,
  });

  factory ReportRecord.fromMap(dynamic map) {
    return ReportRecord(
      id: map['id'] as int,
      name: map['name'] as String,
      type: switch (map['type'] as String) {
        'membership' => ReportType.membership,
        'revenue' => ReportType.revenue,
        _ => ReportType.payments,
      },
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      period: map['period'] as String,
      format: map['format'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'period': period,
      'format': format,
      'status': status,
    };
  }
}

final reportFilterProvider = StateProvider<ReportType?>((ref) => null);

class ReportsNotifier extends AsyncNotifier<List<ReportRecord>> {
  @override
  Future<List<ReportRecord>> build() async {
    return _fetchReports();
  }

  Future<List<ReportRecord>> _fetchReports() async {
    final db = GymDatabase.instance;
    final rows = await db.getReports();
    return rows.map(ReportRecord.fromMap).toList();
  }

  Future<void> addReport({
    required String name,
    required ReportType type,
    required String period,
    required String format,
    String status = 'Ready',
  }) async {
    final db = GymDatabase.instance;
    await db.insertReport({
      'name': name,
      'type': type.name,
      'created_at': DateTime.now().toIso8601String(),
      'period': period,
      'format': format,
      'status': status,
    });
    state = await AsyncValue.guard(() => _fetchReports());
  }

  Future<void> deleteReport(int id) async {
    final db = GymDatabase.instance;
    await db.deleteReport(id);
    state = await AsyncValue.guard(() => _fetchReports());
  }
}

final reportsProvider =
    AsyncNotifierProvider<ReportsNotifier, List<ReportRecord>>(
      () => ReportsNotifier(),
    );

final filteredReportsProvider = Provider<AsyncValue<List<ReportRecord>>>((ref) {
  final filter = ref.watch(reportFilterProvider);
  final reportsAsync = ref.watch(reportsProvider);

  return reportsAsync.whenData((reports) {
    if (filter == null) return reports;
    return reports.where((r) => r.type == filter).toList();
  });
});
