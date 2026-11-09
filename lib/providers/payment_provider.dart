import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/database/db_init.dart'; // Adjust path if needed

class MemberPaymentRecord {
  final int paymentId;
  final String memberName;
  final String membership;
  final DateTime date;
  final double amount;
  final String method;

  const MemberPaymentRecord({
    required this.paymentId,
    required this.memberName,
    required this.membership,
    required this.date,
    required this.amount,
    required this.method,
  });

  factory MemberPaymentRecord.fromMap(Map<String, Object?> map) {
    return MemberPaymentRecord(
      paymentId: map['pay_id'] as int,
      memberName: (map['member_name'] as String?) ?? 'Unknown',
      membership: (map['sub_name'] as String?) ?? 'Membership',
      date:
          DateTime.tryParse(map['payment_date'] as String? ?? '') ??
          DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: (map['method'] as String?) ?? 'Cash',
    );
  }
}

class GymExpenseRecord {
  final String description;
  final String category;
  final DateTime date;
  final double amount;
  final String method;

  const GymExpenseRecord({
    required this.description,
    required this.category,
    required this.date,
    required this.amount,
    required this.method,
  });
}

class PaymentsState {
  final List<MemberPaymentRecord> memberPayments;
  final List<GymExpenseRecord> gymExpenses;

  const PaymentsState({
    required this.memberPayments,
    required this.gymExpenses,
  });

  double get memberTotal =>
      memberPayments.fold(0.0, (acc, p) => acc + p.amount);
  double get expenseTotal => gymExpenses.fold(0.0, (acc, p) => acc + p.amount);
}

class PaymentsNotifier extends AsyncNotifier<PaymentsState> {
  @override
  Future<PaymentsState> build() async {
    return _fetchPaymentsData();
  }

  Future<PaymentsState> _fetchPaymentsData() async {
    final db = await GymDatabase.instance.database;

    final rows = await db.rawQuery('''
      SELECT 
        p.pay_id,
        p.amount,
        p.payment_date,
        p.method,
        m.name AS member_name,
        s.name AS sub_name
      FROM payments p
      JOIN members m ON p.member_id = m.member_id
      LEFT JOIN (
        SELECT id, member_id, sub_id,
               ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY id DESC) as rn
        FROM sub_history
      ) sh ON m.member_id = sh.member_id AND sh.rn = 1
      LEFT JOIN subs s ON sh.sub_id = s.sub_id
      ORDER BY p.payment_date DESC, p.pay_id DESC
    ''');

    final memberPayments = rows.map(MemberPaymentRecord.fromMap).toList();

    final gymExpenses = [
      GymExpenseRecord(
        description: 'Monthly facility rent',
        category: 'Facility',
        date: DateTime(2026, 9, 3),
        amount: 1200,
        method: 'Bank transfer',
      ),
      GymExpenseRecord(
        description: 'Cleaning & supplies',
        category: 'Supplies',
        date: DateTime(2026, 9, 10),
        amount: 145,
        method: 'Card',
      ),
      GymExpenseRecord(
        description: 'Equipment maintenance',
        category: 'Maintenance',
        date: DateTime(2026, 9, 21),
        amount: 320,
        method: 'Cash',
      ),
    ];

    return PaymentsState(
      memberPayments: memberPayments,
      gymExpenses: gymExpenses,
    );
  }

  Future<void> addPayment({
    required int memberId,
    required double amount,
    required String method,
    DateTime? date,
  }) async {
    final gymDb = GymDatabase.instance;
    final paymentDate = date ?? DateTime.now();
    final formattedDate =
        '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}';

    await gymDb.insertPayment({
      'amount': amount,
      'payment_date': formattedDate,
      'method': method,
      'member_id': memberId,
    });

    state = await AsyncValue.guard(() => _fetchPaymentsData());
  }

  Future<void> deletePayment(int paymentId) async {
    final gymDb = GymDatabase.instance;
    await gymDb.deletePayment(paymentId);
    state = await AsyncValue.guard(() => _fetchPaymentsData());
  }
}

final paymentsProvider = AsyncNotifierProvider<PaymentsNotifier, PaymentsState>(
  () => PaymentsNotifier(),
);
