import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';

import '../shared/database/db_init.dart';

class MemberDisplayModel {
  final int id;
  final String name;
  final int age;
  final String membership;
  final String status;
  final String expiryDate;
  final double? price;

  const MemberDisplayModel({
    required this.id,
    required this.name,
    required this.age,
    required this.membership,
    required this.status,
    required this.expiryDate,
    this.price,
  });

  factory MemberDisplayModel.fromMap(Map<String, Object?> map) {
    return MemberDisplayModel(
      id: map['member_id'] as int,
      name: map['name'] as String,
      age: map['age'] as int,
      membership: (map['sub_name'] as String?) ?? 'No membership',
      status: (map['status'] as String?) ?? 'Inactive',
      expiryDate: (map['end_date'] as String?) ?? '-',
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
    );
  }
}

// Database instance provider
final gymDatabaseProvider = Provider<GymDatabase>((ref) {
  return GymDatabase.instance;
});

// Search filter state provider
final memberSearchQueryProvider = StateProvider<String>((ref) => '');

// Members AsyncNotifier managing DB CRUD operations
class MembersNotifier extends AsyncNotifier<List<MemberDisplayModel>> {
  @override
  Future<List<MemberDisplayModel>> build() async {
    return _fetchMembersWithSubscriptions();
  }

  Future<List<MemberDisplayModel>> _fetchMembersWithSubscriptions() async {
    final db = await ref.read(gymDatabaseProvider).database;

    // LEFT JOIN gets all members and attaches their most recent sub_history and sub details
    final rows = await db.rawQuery('''
      SELECT 
        m.member_id,
        m.name,
        m.age,
        s.name AS sub_name,
        s.price,
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
    int createdByUserId = 1, // Default fallback user_id
  }) async {
    final db = await ref.read(gymDatabaseProvider).database;

    await db.transaction((txn) async {
      // 1. Ensure fallback user exists if foreign key requires it
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

      // 2. Insert member
      final memberId = await txn.insert('members', {
        'name': name,
        'age': age,
        'created_by_user_id': createdByUserId,
      });

      // 3. Insert subscription, history, and payment if provided
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

        if (subCost > 0) {
          await txn.insert('payments', {
            'amount': subCost,
            'payment_date': startDate,
            'method': 'Cash',
            'member_id': memberId,
          });
        }
      }
    });

    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
  }

  Future<void> deleteMember(int memberId) async {
    final gymDb = ref.read(gymDatabaseProvider);
    await gymDb.deleteMember(memberId);
    state = await AsyncValue.guard(() => _fetchMembersWithSubscriptions());
  }
}

final membersProvider =
    AsyncNotifierProvider<MembersNotifier, List<MemberDisplayModel>>(
      () => MembersNotifier(),
    );

// Filtered members list provider based on the search query
final filteredMembersProvider = Provider<AsyncValue<List<MemberDisplayModel>>>((
  ref,
) {
  final query = ref.watch(memberSearchQueryProvider).toLowerCase();
  final membersAsync = ref.watch(membersProvider);

  return membersAsync.whenData((members) {
    if (query.isEmpty) return members;
    return members.where((m) => m.name.toLowerCase().contains(query)).toList();
  });
});
