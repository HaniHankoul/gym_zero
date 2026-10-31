import 'package:flutter/material.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';

enum _ReportSource { memberPayments, gymExpenses }

class _MemberPayment {
  final String member;
  final String membership;
  final DateTime date;
  final double amount;
  final String method;

  const _MemberPayment({
    required this.member,
    required this.membership,
    required this.date,
    required this.amount,
    required this.method,
  });
}

class _GymExpense {
  final String description;
  final String category;
  final DateTime date;
  final double amount;
  final String method;

  const _GymExpense({
    required this.description,
    required this.category,
    required this.date,
    required this.amount,
    required this.method,
  });
}

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  static final _memberPayments = [
    _MemberPayment(
      member: 'John Smith',
      membership: 'Gold membership',
      date: DateTime(2026, 9, 28),
      amount: 80,
      method: 'Card',
    ),
    _MemberPayment(
      member: 'Maria Pime',
      membership: 'Silver membership',
      date: DateTime(2026, 9, 25),
      amount: 55,
      method: 'Cash',
    ),
    _MemberPayment(
      member: 'Ranny Smith',
      membership: 'Gold membership',
      date: DateTime(2026, 9, 19),
      amount: 80,
      method: 'Bank transfer',
    ),
    _MemberPayment(
      member: 'Edmar Johnson',
      membership: 'Silver membership',
      date: DateTime(2026, 9, 12),
      amount: 55,
      method: 'Card',
    ),
  ];

  static final _gymExpenses = [
    _GymExpense(
      description: 'Monthly rent',
      category: 'Facility',
      date: DateTime(2026, 9, 3),
      amount: 1200,
      method: 'Bank transfer',
    ),
    _GymExpense(
      description: 'Cleaning supplies',
      category: 'Supplies',
      date: DateTime(2026, 9, 10),
      amount: 145,
      method: 'Card',
    ),
    _GymExpense(
      description: 'Equipment maintenance',
      category: 'Maintenance',
      date: DateTime(2026, 9, 21),
      amount: 320,
      method: 'Cash',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final memberTotal = _memberPayments.fold<double>(
      0,
      (total, payment) => total + payment.amount,
    );
    final expenseTotal = _gymExpenses.fold<double>(
      0,
      (total, payment) => total + payment.amount,
    );

    return Container(
      color: AppThemeDark.primaryBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeneralSizes.largeSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payments',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppThemeDark.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Track membership income and gym expenses for the last month.',
                        style: TextStyle(color: AppThemeDark.textSecondary),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showReportDialog(context),
                  icon: const Icon(Icons.assessment_outlined, size: 18),
                  label: const Text('Create report'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppThemeDark.primary,
                    foregroundColor: AppThemeDark.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SummaryRow(memberTotal: memberTotal, expenseTotal: expenseTotal),
            const SizedBox(height: 28),
            _SectionTitle(
              title: 'Member payments',
              subtitle: 'Membership payments received in September 2026',
              icon: Icons.people_alt_outlined,
            ),
            const SizedBox(height: 12),
            _MemberPaymentsTable(payments: _memberPayments),
            const SizedBox(height: 28),
            _SectionTitle(
              title: 'Gym payments',
              subtitle: 'Operating expenses paid in September 2026',
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 12),
            _GymExpensesTable(expenses: _gymExpenses),
          ],
        ),
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    final result = await showDialog<_ReportSettings>(
      context: context,
      builder: (context) => const _ReportDialog(),
    );
    if (!context.mounted || result == null) return;

    final source = result.source == _ReportSource.memberPayments
        ? 'member payments'
        : 'gym expenses';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Report ready: $source, ${_formatDate(result.start)} - '
          '${_formatDate(result.end)}${result.includeHistory ? ', with subscription history' : ''}.',
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double memberTotal;
  final double expenseTotal;

  const _SummaryRow({required this.memberTotal, required this.expenseTotal});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 650
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _SummaryCard(
              width: width,
              label: 'Membership income',
              value: _formatCurrency(memberTotal),
              detail: '4 payments received',
              icon: Icons.trending_up,
              color: AppThemeDark.success,
            ),
            _SummaryCard(
              width: width,
              label: 'Gym expenses',
              value: _formatCurrency(expenseTotal),
              detail: '3 payments recorded',
              icon: Icons.trending_down,
              color: AppThemeDark.warning,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppThemeDark.secondary,
          borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
          border: Border.all(color: AppThemeDark.borderPrimary),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.14),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppThemeDark.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppThemeDark.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(detail, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppThemeDark.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppThemeDark.textWhite,
                fontSize: 18,
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
      ],
    );
  }
}

class _MemberPaymentsTable extends StatelessWidget {
  final List<_MemberPayment> payments;

  const _MemberPaymentsTable({required this.payments});

  @override
  Widget build(BuildContext context) {
    return _TableShell(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Member')),
          DataColumn(label: Text('Membership')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Method')),
          DataColumn(label: Text('Amount')),
        ],
        rows: [
          for (final payment in payments)
            DataRow(
              cells: [
                DataCell(Text(payment.member)),
                DataCell(Text(payment.membership)),
                DataCell(Text(_formatDate(payment.date))),
                DataCell(_PaymentMethod(method: payment.method)),
                DataCell(Text(_formatCurrency(payment.amount))),
              ],
            ),
        ],
      ),
    );
  }
}

class _GymExpensesTable extends StatelessWidget {
  final List<_GymExpense> expenses;

  const _GymExpensesTable({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return _TableShell(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Method')),
          DataColumn(label: Text('Amount')),
        ],
        rows: [
          for (final expense in expenses)
            DataRow(
              cells: [
                DataCell(Text(expense.description)),
                DataCell(Text(expense.category)),
                DataCell(Text(_formatDate(expense.date))),
                DataCell(_PaymentMethod(method: expense.method)),
                DataCell(Text(_formatCurrency(expense.amount))),
              ],
            ),
        ],
      ),
    );
  }
}

class _TableShell extends StatelessWidget {
  final Widget child;

  const _TableShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final String method;

  const _PaymentMethod({required this.method});

  @override
  Widget build(BuildContext context) {
    return Text(
      method,
      style: const TextStyle(color: AppThemeDark.textSecondary),
    );
  }
}

class _ReportSettings {
  final DateTime start;
  final DateTime end;
  final _ReportSource source;
  final bool includeHistory;

  const _ReportSettings({
    required this.start,
    required this.end,
    required this.source,
    required this.includeHistory,
  });
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  DateTime _start = DateTime(2026, 9, 1);
  DateTime _end = DateTime(2026, 9, 30);
  _ReportSource _source = _ReportSource.memberPayments;
  bool _includeHistory = false;

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_start.isAfter(_end)) _start = _end;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create payment report'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Report period',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Start date',
                    date: _start,
                    onPressed: () => _pickDate(start: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateButton(
                    label: 'End date',
                    date: _end,
                    onPressed: () => _pickDate(start: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Include in report',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SegmentedButton<_ReportSource>(
              segments: [
                ButtonSegment(
                  value: _ReportSource.memberPayments,
                  label: const Text('Member payments'),
                  icon: const Icon(Icons.people_alt_outlined),
                ),
                ButtonSegment(
                  value: _ReportSource.gymExpenses,
                  label: const Text('Gym expenses'),
                  icon: const Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_source},
              onSelectionChanged: (selection) {
                setState(() => _source = selection.first);
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show member subscription history'),
              value: _includeHistory,
              onChanged: (value) =>
                  setState(() => _includeHistory = value ?? false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _ReportSettings(
              start: _start,
              end: _end,
              source: _source,
              includeHistory: _includeHistory,
            ),
          ),
          child: const Text('Generate report'),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onPressed;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 3),
          Text(_formatDate(date)),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';
