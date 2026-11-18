import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/payment_provider.dart';
import '../../providers/reports_provider.dart';
import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../shared/widgets/custom_text_field.dart';

enum _ReportSource { memberPayments, gymExpenses }

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return Container(
      color: AppThemeDark.primaryBackground,
      child: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomText(
              text: 'Failed to load payments: $err',
              color: AppThemeDark.error,
            ),
          ),
        ),
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(GeneralSizes.largeSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PaymentsHeader(
                  onReportTap: () => _showReportDialog(context, ref),
                ),
                const SizedBox(height: 24),
                _SummaryRow(
                  memberTotal: data.memberTotal,
                  memberCount: data.memberPayments.length,
                  expenseTotal: data.expenseTotal,
                  expenseCount: data.gymExpenses.length,
                ),
                const SizedBox(height: 32),
                _SectionTitle(
                  title: 'Member Payments',
                  subtitle:
                      '${data.memberPayments.length} transactions recorded',
                  icon: Icons.people_alt_outlined,
                ),
                const SizedBox(height: 14),
                _MemberPaymentsViewer(
                  payments: data.memberPayments,
                  onDelete: (id) =>
                      ref.read(paymentsProvider.notifier).deletePayment(id),
                ),
                const SizedBox(height: 32),
                _SectionTitle(
                  title: 'Gym Expenses',
                  subtitle:
                      '${data.gymExpenses.length} operational costs recorded',
                  icon: Icons.account_balance_wallet_outlined,
                  trailing: FilledButton.icon(
                    onPressed: () => _showAddExpenseDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18, color: Colors.black),
                    label: const Text(
                      'Add expense',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppThemeDark.primary,
                      foregroundColor: AppThemeDark.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _GymExpensesViewer(
                  expenses: data.gymExpenses,
                  onDelete: (id) =>
                      ref.read(paymentsProvider.notifier).deleteExpense(id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddExpenseDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final expenseData = await showDialog<_NewExpenseData>(
      context: context,
      builder: (context) => const _AddExpenseDialog(),
    );
    if (!context.mounted || expenseData == null) return;

    await ref
        .read(paymentsProvider.notifier)
        .addExpense(
          description: expenseData.description,
          category: expenseData.category,
          amount: expenseData.amount,
          method: expenseData.method,
          date: expenseData.date,
        );
  }

  Future<void> _showReportDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_ReportSettings>(
      context: context,
      builder: (context) => const _ReportDialog(),
    );
    if (!context.mounted || result == null) return;

    final period = '${_formatDate(result.start)} - ${_formatDate(result.end)}';
    final isPayments = result.source == _ReportSource.memberPayments;
    final reportName =
        '${isPayments ? "Payments report" : "Gym expenses report"} - ${_formatDate(result.start)}';

    await ref
        .read(reportsProvider.notifier)
        .addReport(
          name: reportName,
          type: ReportType.payments,
          period: period,
          format: 'PDF',
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$reportName created and saved to Reports history.'),
        ),
      );
    }
  }
}

class _PaymentsHeader extends StatelessWidget {
  final VoidCallback onReportTap;

  const _PaymentsHeader({required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payments',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppThemeDark.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Real-time overview of revenue collection and gym operating expenses.',
                style: TextStyle(color: AppThemeDark.textSecondary),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onReportTap,
          icon: const Icon(
            Icons.assessment_outlined,
            size: 18,
            color: Colors.black,
          ),
          label: const Text(
            'Create report',
            style: TextStyle(color: Colors.black),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppThemeDark.primary,
            foregroundColor: AppThemeDark.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double memberTotal;
  final int memberCount;
  final double expenseTotal;
  final int expenseCount;

  const _SummaryRow({
    required this.memberTotal,
    required this.memberCount,
    required this.expenseTotal,
    required this.expenseCount,
  });

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
              label: 'Membership Income',
              value: _formatCurrency(memberTotal),
              detail: '$memberCount transactions recorded',
              icon: Icons.trending_up,
              color: AppThemeDark.success,
            ),
            _SummaryCard(
              width: width,
              label: 'Gym Expenses',
              value: _formatCurrency(expenseTotal),
              detail: '$expenseCount expenses logged',
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
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.14),
              foregroundColor: color,
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: 16),
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
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppThemeDark.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
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
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  fontSize: 17,
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
    );
  }
}

class _MemberPaymentsViewer extends StatelessWidget {
  final List<MemberPaymentRecord> payments;
  final ValueChanged<int> onDelete;

  const _MemberPaymentsViewer({required this.payments, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const _EmptyStateCard(message: 'No member payments recorded yet.');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments.length,
        separatorBuilder: (_, __) => Divider(
          color: AppThemeDark.borderPrimary.withValues(alpha: 0.5),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppThemeDark.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person,
                    color: AppThemeDark.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.memberName,
                        style: const TextStyle(
                          color: AppThemeDark.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        payment.membership,
                        style: const TextStyle(
                          color: AppThemeDark.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _MethodBadge(method: payment.method),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${_formatCurrency(payment.amount)}',
                      style: const TextStyle(
                        color: AppThemeDark.success,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(payment.date),
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => onDelete(payment.paymentId),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppThemeDark.textSecondary,
                  tooltip: 'Delete transaction',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GymExpensesViewer extends StatelessWidget {
  final List<dynamic> expenses;
  final ValueChanged<int> onDelete;

  const _GymExpensesViewer({required this.expenses, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const _EmptyStateCard(message: 'No gym expenses recorded yet.');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length,
        separatorBuilder: (_, __) => Divider(
          color: AppThemeDark.borderPrimary.withValues(alpha: 0.5),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppThemeDark.warning.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppThemeDark.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: const TextStyle(
                          color: AppThemeDark.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        expense.category,
                        style: const TextStyle(
                          color: AppThemeDark.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _MethodBadge(method: expense.method),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${_formatCurrency(expense.amount)}',
                      style: const TextStyle(
                        color: AppThemeDark.warning,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(expense.date),
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => onDelete(expense.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppThemeDark.textSecondary,
                  tooltip: 'Delete expense',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;

  const _MethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemeDark.primaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: Text(
        method,
        style: const TextStyle(
          color: AppThemeDark.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;

  const _EmptyStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppThemeDark.textSecondary),
        ),
      ),
    );
  }
}

// --- Add Expense Dialog ---

class _NewExpenseData {
  final String description;
  final String category;
  final double amount;
  final String method;
  final DateTime date;

  const _NewExpenseData({
    required this.description,
    required this.category,
    required this.amount,
    required this.method,
    required this.date,
  });
}

class _AddExpenseDialog extends StatefulWidget {
  const _AddExpenseDialog();

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _category = 'Facility';
  String _method = 'Cash';
  DateTime _date = DateTime.now();

  static const _categories = [
    'Facility',
    'Equipment',
    'Maintenance',
    'Utilities',
    'Supplies',
    'Salaries',
    'Other',
  ];

  static const _methods = ['Cash', 'Card', 'Bank transfer'];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    Navigator.of(context).pop(
      _NewExpenseData(
        description: _descriptionController.text.trim(),
        category: _category,
        amount: amount,
        method: _method,
        date: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeDark.secondary,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppThemeDark.borderPrimary),
      ),
      title: CustomText(
        text: 'Add Gym Expense',
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _descriptionController,
                  autofocus: true,
                  hintText: 'Description (e.g. Monthly rent)',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a description'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _amountController,
                  hintText: 'Amount (\$)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(
                    color: AppThemeDark.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: AppThemeDark.primaryBackground,
                  style: const TextStyle(color: AppThemeDark.textWhite),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppThemeDark.primaryBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppThemeDark.borderPrimary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppThemeDark.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              color: AppThemeDark.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _method,
                            dropdownColor: AppThemeDark.primaryBackground,
                            style: const TextStyle(
                              color: AppThemeDark.textWhite,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppThemeDark.primaryBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppThemeDark.borderPrimary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppThemeDark.primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _methods
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _method = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(
                              color: AppThemeDark.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: _DateButton(
                              label: 'Expense date',
                              date: _date,
                              onPressed: _pickDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppThemeDark.primary),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppThemeDark.primary,
            foregroundColor: AppThemeDark.textPrimary,
          ),
          child: const Text(
            'Add expense',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

// --- Report Dialog ---

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
      backgroundColor: AppThemeDark.primaryBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppThemeDark.borderPrimary),
      ),
      title: CustomText(
        text: 'Create payment report',
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'Report period',
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
            CustomText(
              text: 'Include in report',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 10),
            SegmentedButton<_ReportSource>(
              segments: const [
                ButtonSegment(
                  value: _ReportSource.memberPayments,
                  label: Text('Member payments'),
                  icon: Icon(Icons.people_alt_outlined),
                ),
                ButtonSegment(
                  value: _ReportSource.gymExpenses,
                  label: Text('Gym expenses'),
                  icon: Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_source},
              style: ButtonStyle(
                foregroundColor: const WidgetStatePropertyAll(
                  AppThemeDark.textWhite,
                ),
                overlayColor: WidgetStatePropertyAll(
                  AppThemeDark.primary.withValues(alpha: 0.12),
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: AppThemeDark.borderPrimary),
                ),
              ),
              onSelectionChanged: (selection) {
                setState(() => _source = selection.first);
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppThemeDark.primary,
              checkColor: AppThemeDark.textPrimary,
              title: const Text(
                'Show member subscription history',
                style: TextStyle(color: AppThemeDark.textWhite),
              ),
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
          style: TextButton.styleFrom(foregroundColor: AppThemeDark.primary),
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
          style: FilledButton.styleFrom(
            backgroundColor: AppThemeDark.primary,
            foregroundColor: AppThemeDark.textPrimary,
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
        foregroundColor: AppThemeDark.textWhite,
        side: const BorderSide(color: AppThemeDark.borderPrimary),
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
