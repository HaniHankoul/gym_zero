import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';

import '../shared/database/db_init.dart';
import 'payment_provider.dart';

class MemberDisplayModel {
  final int id;
  final String name;
  final int age;
  final String membership;
  final String status;
  final String expiryDate;
  final double? price;
  final int? subId;
  final int? subHistoryId;

  const MemberDisplayModel({
    required this.id,
    required this.name,
    required this.age,
    required this.membership,
    required this.status,
    required this.expiryDate,
    this.price,
    this.subId,
    this.subHistoryId,
  });

  bool get hasActiveSubscription => status.toLowerCase() == 'active';

  factory MemberDisplayModel.fromMap(Map<String, Object?> map) {
    return MemberDisplayModel(
      id: map['member_id'] as int,
      name: map['name'] as String,
      age: map['age'] as int,
      membership: (map['sub_name'] as String?) ?? 'No membership',
      status: (map['status'] as String?) ?? 'Inactive',
      expiryDate: (map['end_date'] as String?) ?? '-',
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      subId: map['sub_id'] as int?,
      subHistoryId: map['sub_history_id'] as int?,
    );
  }
}

final gymDatabaseProvider = Provider<GymDatabase>((ref) {
  return GymDatabase.instance;
});

final memberSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

class MembersNotifier extends AsyncNotifier<List<MemberDisplayModel>> {
  @override
  Future<List<MemberDisplayModel>> build() async {
    return _fetchMembersWithSubscriptions();
  }

  Future<List<MemberDisplayModel>> _fetchMembersWithSubscriptions() async {
    final db = await ref.read(gymDatabaseProvider).database;

    final rows = await db.rawQuery('''
      SELECT 
        m.member_id,
        m.name,
        m.age,
        s.sub_id,
        s.name AS sub_name,
        s.price,
        sh.id AS sub_history_id,
        sh.end_date,
        COALESCE(sh.status, 'Inactive') AS status
      FROM members m
      LEFT JOIN (
        SELECT id, member_id, sub_id, end_date, status,
               ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY id DESC) as rn
        FROM sub_history
      ) sh ON m.member_id = sh.member_id AND sh.rn = 1
      LEFT JOIN subs s ON sh.sub_id = s.sub_id
      ORDER BY m.name COLLATE NOCASE ASC
    ''');

    return rows.map(MemberDisplayModel.fromMap).toList();
  }

  Future<void> addMemberWithSubscription({
    required String name,
    required int age,
    int? durationMonths,
    double? price,
    int createdByUserId = 1,
  }) async {
    final db = await ref.read(gymDatabaseProvider).database;

    await db.transaction((txn) async {
      final userCheck = await txn.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [createdByUserId],
      );
      if (userCheck.isEmpty) {
        await txn.insert('users', {
          'user_id': createdByUserId,
          'name': 'Admin',
          'password': 'admin',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      final memberId = await txn.insert('members', {
        'name': name,
        'age': age,
        'created_by_user_id': createdByUserId,
      });

      if (durationMonths != null && durationMonths > 0) {
        final subCost = price ?? 0.0;
        final subName = '$durationMonths Months Plan';

        final subId = await txn.insert('subs', {
          'name': subName,
          'duration_months': durationMonths,
          'price': subCost,
        });

        final now = DateTime.now();
        final startDate =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final expiry = DateTime(now.year, now.month + durationMonths, now.day);
        final endDate =
            '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';

        await txn.insert('sub_history', {
          'start_date': startDate,
          'end_date': endDate,
          'status': 'Active',
          'member_id': memberId,
          'sub_id': subId,
        });

        await txn.insert('payments', {
          'amount': subCost,
          'payment_date': startDate,
          'method': 'Cash',
          'member_id': memberId,
        });
      }
    });

    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
    ref.invalidate(paymentsProvider);
  }

  Future<void> addOrRenewSubscription({
    required int memberId,
    required int durationMonths,
    required double price,
  }) async {
    final db = await ref.read(gymDatabaseProvider).database;

    await db.transaction((txn) async {
      final subCost = price;
      final subName = '$durationMonths Months Plan';

      final subId = await txn.insert('subs', {
        'name': subName,
        'duration_months': durationMonths,
        'price': subCost,
      });

      final now = DateTime.now();
      final startDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final expiry = DateTime(now.year, now.month + durationMonths, now.day);
      final endDate =
          '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';

      await txn.insert('sub_history', {
        'start_date': startDate,
        'end_date': endDate,
        'status': 'Active',
        'member_id': memberId,
        'sub_id': subId,
      });

      await txn.insert('payments', {
        'amount': subCost,
        'payment_date': startDate,
        'method': 'Cash',
        'member_id': memberId,
      });
    });

    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
    ref.invalidate(paymentsProvider);
  }

  Future<void> editSubscription({
    required int subId,
    required int subHistoryId,
    required int durationMonths,
    required double price,
  }) async {
    final db = await ref.read(gymDatabaseProvider).database;

    await db.transaction((txn) async {
      final subName = '$durationMonths Months Plan';
      await txn.update(
        'subs',
        {'name': subName, 'duration_months': durationMonths, 'price': price},
        where: 'sub_id = ?',
        whereArgs: [subId],
      );

      final now = DateTime.now();
      final expiry = DateTime(now.year, now.month + durationMonths, now.day);
      final endDate =
          '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';

      await txn.update(
        'sub_history',
        {'end_date': endDate, 'status': 'Active'},
        where: 'id = ?',
        whereArgs: [subHistoryId],
      );
    });

    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
    ref.invalidate(paymentsProvider);
  }

  Future<void> cancelSubscription(int subHistoryId) async {
    final db = await ref.read(gymDatabaseProvider).database;
    await db.update(
      'sub_history',
      {'status': 'Cancelled'},
      where: 'id = ?',
      whereArgs: [subHistoryId],
    );
    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
  }

  Future<void> deleteMember(int memberId) async {
    final gymDb = ref.read(gymDatabaseProvider);
    await gymDb.deleteMember(memberId);
    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
    ref.invalidate(paymentsProvider);
  }
}

final membersProvider =
    AsyncNotifierProvider<MembersNotifier, List<MemberDisplayModel>>(
      () => MembersNotifier(),
    );

final filteredMembersProvider =
    Provider.autoDispose<AsyncValue<List<MemberDisplayModel>>>((ref) {
      final query = ref.watch(memberSearchQueryProvider).toLowerCase();
      final membersAsync = ref.watch(membersProvider);

      return membersAsync.whenData((members) {
        if (query.isEmpty) return members;
        return members
            .where((m) => m.name.toLowerCase().contains(query))
            .toList();
      });
    });
