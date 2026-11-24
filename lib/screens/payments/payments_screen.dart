import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../providers/payment_provider.dart';
import '../../providers/reports_provider.dart';
import '../../shared/constants/general_sizes.dart';
import '../../shared/services/excel_report_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'widgets/gym_expenses_log_screen.dart';
import 'widgets/member_payments_log_screen.dart';

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
          final netRevenue = data.memberTotal - data.expenseTotal;

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
                  totalRevenue: netRevenue,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Transaction Logs',
                  style: TextStyle(
                    color: AppThemeDark.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Open a full searchable log to browse, filter, or manage records.',
                  style: TextStyle(
                    color: AppThemeDark.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isStacked = constraints.maxWidth < 720;
                    final cardWidth = isStacked
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _LogNavigationCard(
                            title: 'Member Payments',
                            subtitle: 'View and search all incoming membership transactions.',
                            countText:
                                '${data.memberPayments.length} ${data.memberPayments.length == 1 ? 'record' : 'records'}',
                            totalText: '+${_formatCurrency(data.memberTotal)}',
                            accentColor: AppThemeDark.success,
                            icon: Icons.people_alt_outlined,
                            buttonLabel: 'Open Payments Log',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MemberPaymentsLogScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _LogNavigationCard(
                            title: 'Gym Expenses',
                            subtitle: 'View, search, and record gym operating expenses.',
                            countText:
                                '${data.gymExpenses.length} ${data.gymExpenses.length == 1 ? 'record' : 'records'}',
                            totalText: '-${_formatCurrency(data.expenseTotal)}',
                            accentColor: AppThemeDark.warning,
                            icon: Icons.account_balance_wallet_outlined,
                            buttonLabel: 'Open Expenses Log',
                            secondaryAction: OutlinedButton.icon(
                              onPressed: () =>
                                  showAddExpenseDialog(context, ref),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add expense'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppThemeDark.textWhite,
                                side: BorderSide(
                                  color: AppThemeDark.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GymExpensesLogScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_ReportSettings>(
      context: context,
      builder: (context) => const _ReportDialog(),
    );
    if (!context.mounted || result == null) return;

    final paymentsData = ref.read(paymentsProvider).value;
    if (paymentsData == null) return;

    final isPayments = result.source == _ReportSource.memberPayments;

    try {
      final generated = await ExcelReportService.generatePaymentsExcelReport(
        source: isPayments
            ? ExcelReportSource.memberPayments
            : ExcelReportSource.gymExpenses,
        startDate: result.start,
        endDate: result.end,
        allMemberPayments: paymentsData.memberPayments,
        allGymExpenses: paymentsData.gymExpenses,
        includeSubscriptionHistory: isPayments && result.includeHistory,
      );

      final period =
          '${_formatDate(result.start)} - ${_formatDate(result.end)}';
      final reportName =
          '${isPayments ? "Payments report" : "Gym expenses report"} - ${_formatDate(result.start)}';

      await ref
          .read(reportsProvider.notifier)
          .addReport(
            name: reportName,
            type: ReportType.payments,
            period: period,
            format: 'XLSX',
            filePath: generated.filePath,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 6),
            content: Text(
              'Excel saved (${generated.recordCount} rows): ${generated.fileName}',
            ),
            action: SnackBarAction(
              label: 'Open',
              textColor: AppThemeDark.primary,
              onPressed: () => OpenFilex.open(generated.filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppThemeDark.error,
            content: Text('Failed to generate Excel report: $e'),
          ),
        );
      }
    }
  }
}

/// Shared helper so both PaymentsScreen and GymExpensesLogScreen can add expenses.
Future<void> showAddExpenseDialog(BuildContext context, WidgetRef ref) async {
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
  final double totalRevenue;

  const _SummaryRow({
    required this.memberTotal,
    required this.memberCount,
    required this.expenseTotal,
    required this.expenseCount,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 650
            ? constraints.maxWidth
            : constraints.maxWidth < 1000
            ? (constraints.maxWidth - 16) / 2
            : (constraints.maxWidth - 32) / 3;

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
            _SummaryCard(
              width: width,
              label: 'Total Revenue',
              value: _formatCurrency(totalRevenue),
              detail: totalRevenue >= 0 ? 'Net Profit' : 'Net Loss',
              icon: totalRevenue >= 0 ? Icons.trending_up : Icons.trending_down,
              color: totalRevenue >= 0
                  ? AppThemeDark.success
                  : AppThemeDark.error,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _LogNavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String countText;
  final String totalText;
  final Color accentColor;
  final IconData icon;
  final String buttonLabel;
  final Widget? secondaryAction;
  final VoidCallback onTap;

  const _LogNavigationCard({
    required this.title,
    required this.subtitle,
    required this.countText,
    required this.totalText,
    required this.accentColor,
    required this.icon,
    required this.buttonLabel,
    required this.onTap,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeDark.secondary,
      borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
            border: Border.all(color: AppThemeDark.borderPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accentColor.withValues(alpha: 0.14),
                    foregroundColor: accentColor,
                    child: Icon(icon, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
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
                        const SizedBox(height: 2),
                        Text(
                          countText,
                          style: const TextStyle(
                            color: AppThemeDark.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    totalText,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppThemeDark.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                color: AppThemeDark.borderPrimary.withValues(alpha: 0.6),
                height: 1,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: Colors.black,
                    ),
                    label: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppThemeDark.primary,
                      foregroundColor: AppThemeDark.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                    ),
                  ),
                  ?secondaryAction,
                ],
              ),
            ],
          ),
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
        side: const BorderSide(color: AppThemeDark.borderPrimary),
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
                  initialValue: _category,
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
                      borderSide: const BorderSide(
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
                            initialValue: _method,
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
                                borderSide: const BorderSide(
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
  late DateTime _start;
  late DateTime _end;
  _ReportSource _source = _ReportSource.memberPayments;
  bool _includeHistory = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _end = now;
  }

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
        side: const BorderSide(color: AppThemeDark.borderPrimary),
      ),
      title: CustomText(
        text: 'Create Excel report',
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
            if (_source == _ReportSource.memberPayments)
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
          child: const Text(
            'Export Excel',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
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
