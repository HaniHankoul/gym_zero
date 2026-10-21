import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

class GymDatabase {
  GymDatabase._();

  static final GymDatabase instance = GymDatabase._();

  static const _databaseName = 'gym_zero.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasePath = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
				CREATE TABLE users (
					user_id INTEGER PRIMARY KEY AUTOINCREMENT,
					name TEXT NOT NULL,
					password TEXT NOT NULL
				)
			''');

      await txn.execute('''
				CREATE TABLE members (
					member_id INTEGER PRIMARY KEY AUTOINCREMENT,
					name TEXT NOT NULL,
					age INTEGER NOT NULL,
					created_by_user_id INTEGER NOT NULL,
					FOREIGN KEY (created_by_user_id) REFERENCES users (user_id)
						ON DELETE CASCADE ON UPDATE CASCADE
				)
			''');

      await txn.execute('''
				CREATE TABLE subs (
					sub_id INTEGER PRIMARY KEY AUTOINCREMENT,
					name TEXT NOT NULL,
					duration_months INTEGER NOT NULL,
					price REAL NOT NULL
				)
			''');

      await txn.execute('''
				CREATE TABLE payments (
					pay_id INTEGER PRIMARY KEY AUTOINCREMENT,
					amount REAL NOT NULL,
					payment_date TEXT NOT NULL,
					method TEXT NOT NULL,
					member_id INTEGER NOT NULL,
					FOREIGN KEY (member_id) REFERENCES members (member_id)
						ON DELETE CASCADE ON UPDATE CASCADE
				)
			''');

      await txn.execute('''
				CREATE TABLE attendance (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					check_in_time TEXT NOT NULL,
					check_out_time TEXT,
					member_id INTEGER NOT NULL,
					FOREIGN KEY (member_id) REFERENCES members (member_id)
						ON DELETE CASCADE ON UPDATE CASCADE
				)
			''');

      await txn.execute('''
				CREATE TABLE sub_history (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					start_date TEXT NOT NULL,
					end_date TEXT NOT NULL,
					status TEXT NOT NULL,
					member_id INTEGER NOT NULL,
					sub_id INTEGER NOT NULL,
					FOREIGN KEY (member_id) REFERENCES members (member_id)
						ON DELETE CASCADE ON UPDATE CASCADE,
					FOREIGN KEY (sub_id) REFERENCES subs (sub_id)
						ON DELETE CASCADE ON UPDATE CASCADE
				)
			''');

      await txn.execute(
        'CREATE INDEX idx_members_created_by_user ON members (created_by_user_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_payments_member ON payments (member_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_attendance_member ON attendance (member_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_sub_history_member ON sub_history (member_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_sub_history_sub ON sub_history (sub_id)',
      );
    });
  }

  Future<int> insertUser(Map<String, Object?> user) async {
    return (await database).insert('users', user);
  }

  Future<List<Map<String, Object?>>> getUsers() async {
    return (await database).query('users', orderBy: 'name COLLATE NOCASE');
  }

  Future<Map<String, Object?>?> getUser(int userId) async {
    final rows = await (await database).query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateUser(int userId, Map<String, Object?> values) async {
    return (await database).update(
      'users',
      values,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int userId) async {
    return (await database).delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> insertMember(Map<String, Object?> member) async {
    return (await database).insert('members', member);
  }

  Future<List<Map<String, Object?>>> getMembers() async {
    return (await database).query('members', orderBy: 'name COLLATE NOCASE');
  }

  Future<Map<String, Object?>?> getMember(int memberId) async {
    final rows = await (await database).query(
      'members',
      where: 'member_id = ?',
      whereArgs: [memberId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateMember(int memberId, Map<String, Object?> values) async {
    return (await database).update(
      'members',
      values,
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
  }

  Future<int> deleteMember(int memberId) async {
    return (await database).delete(
      'members',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
  }

  Future<int> insertSubscription(Map<String, Object?> subscription) async {
    return (await database).insert('subs', subscription);
  }

  Future<List<Map<String, Object?>>> getSubscriptions() async {
    return (await database).query('subs', orderBy: 'name COLLATE NOCASE');
  }

  Future<Map<String, Object?>?> getSubscription(int subId) async {
    final rows = await (await database).query(
      'subs',
      where: 'sub_id = ?',
      whereArgs: [subId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateSubscription(int subId, Map<String, Object?> values) async {
    return (await database).update(
      'subs',
      values,
      where: 'sub_id = ?',
      whereArgs: [subId],
    );
  }

  Future<int> deleteSubscription(int subId) async {
    return (await database).delete(
      'subs',
      where: 'sub_id = ?',
      whereArgs: [subId],
    );
  }

  Future<int> insertPayment(Map<String, Object?> payment) async {
    return (await database).insert('payments', payment);
  }

  Future<List<Map<String, Object?>>> getPayments({int? memberId}) async {
    return (await database).query(
      'payments',
      where: memberId == null ? null : 'member_id = ?',
      whereArgs: memberId == null ? null : [memberId],
      orderBy: 'payment_date DESC',
    );
  }

  Future<Map<String, Object?>?> getPayment(int paymentId) async {
    final rows = await (await database).query(
      'payments',
      where: 'pay_id = ?',
      whereArgs: [paymentId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updatePayment(int paymentId, Map<String, Object?> values) async {
    return (await database).update(
      'payments',
      values,
      where: 'pay_id = ?',
      whereArgs: [paymentId],
    );
  }

  Future<int> deletePayment(int paymentId) async {
    return (await database).delete(
      'payments',
      where: 'pay_id = ?',
      whereArgs: [paymentId],
    );
  }

  Future<int> insertAttendance(Map<String, Object?> attendance) async {
    return (await database).insert('attendance', attendance);
  }

  Future<List<Map<String, Object?>>> getAttendance({int? memberId}) async {
    return (await database).query(
      'attendance',
      where: memberId == null ? null : 'member_id = ?',
      whereArgs: memberId == null ? null : [memberId],
      orderBy: 'check_in_time DESC',
    );
  }

  Future<Map<String, Object?>?> getAttendanceRecord(int attendanceId) async {
    final rows = await (await database).query(
      'attendance',
      where: 'id = ?',
      whereArgs: [attendanceId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateAttendance(
    int attendanceId,
    Map<String, Object?> values,
  ) async {
    return (await database).update(
      'attendance',
      values,
      where: 'id = ?',
      whereArgs: [attendanceId],
    );
  }

  Future<int> deleteAttendance(int attendanceId) async {
    return (await database).delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [attendanceId],
    );
  }

  Future<int> insertSubscriptionHistory(Map<String, Object?> history) async {
    return (await database).insert('sub_history', history);
  }

  Future<List<Map<String, Object?>>> getSubscriptionHistory({
    int? memberId,
  }) async {
    return (await database).query(
      'sub_history',
      where: memberId == null ? null : 'member_id = ?',
      whereArgs: memberId == null ? null : [memberId],
      orderBy: 'start_date DESC',
    );
  }

  Future<Map<String, Object?>?> getSubscriptionHistoryEntry(
    int historyId,
  ) async {
    final rows = await (await database).query(
      'sub_history',
      where: 'id = ?',
      whereArgs: [historyId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateSubscriptionHistory(
    int historyId,
    Map<String, Object?> values,
  ) async {
    return (await database).update(
      'sub_history',
      values,
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<int> deleteSubscriptionHistory(int historyId) async {
    return (await database).delete(
      'sub_history',
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
