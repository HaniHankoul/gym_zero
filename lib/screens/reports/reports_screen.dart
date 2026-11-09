import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReportsAsync = ref.watch(reportsProvider);
    final filteredReportsAsync = ref.watch(filteredReportsProvider);
    final selectedFilter = ref.watch(reportFilterProvider);

    return Container(
      color: AppThemeDark.primaryBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeneralSizes.largeSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(onGenerate: () => _showGenerateDialog(context, ref)),
            const SizedBox(height: 24),
            _SummaryRow(reports: allReportsAsync.value ?? []),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'Report history',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppThemeDark.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _FilterMenu(
                  selected: selectedFilter,
                  onChanged: (value) =>
                      ref.read(reportFilterProvider.notifier).state = value,
                ),
              ],
            ),
            const SizedBox(height: 12),
            filteredReportsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CustomText(
                    text: 'Failed to load reports: $err',
                    color: AppThemeDark.error,
                  ),
                ),
              ),
              data: (reports) => _ReportsTable(
                reports: reports,
                onDownload: (report) =>
                    _showMessage(context, '${report.name} downloaded.'),
                onDelete: (id) =>
                    ref.read(reportsProvider.notifier).deleteReport(id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGenerateDialog(BuildContext context, WidgetRef ref) async {
    final reportData = await showDialog<_NewReportData>(
      context: context,
      builder: (context) => const _GenerateReportDialog(),
    );
    if (!context.mounted || reportData == null) return;

    await ref
        .read(reportsProvider.notifier)
        .addReport(
          name: reportData.name,
          type: reportData.type,
          period: reportData.period,
          format: reportData.format,
        );

    if (context.mounted) {
      _showMessage(context, '${reportData.name} is ready.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PageHeader extends StatelessWidget {
  final VoidCallback onGenerate;

  const _PageHeader({required this.onGenerate});

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
                'Reports',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppThemeDark.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Keep every membership and payment report in one place.',
                style: TextStyle(color: AppThemeDark.textSecondary),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onGenerate,
          icon: const Icon(
            Icons.assessment_outlined,
            size: 18,
            color: Colors.black,
          ),
          label: const Text(
            'Generate report',
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
  final List<ReportRecord> reports;

  const _SummaryRow({required this.reports});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonthCount = reports.where((r) {
      return r.createdAt.year == now.year && r.createdAt.month == now.month;
    }).length;

    final latestReport = reports.isNotEmpty
        ? _formatRelativeDate(reports.first.createdAt)
        : 'None';

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 650
            ? constraints.maxWidth
            : (constraints.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _SummaryCard(
              width: width,
              label: 'Total reports',
              value: '${reports.length}',
              detail: 'Generated reports',
              icon: Icons.description_outlined,
              color: AppThemeDark.primary,
            ),
            _SummaryCard(
              width: width,
              label: 'This month',
              value: '$thisMonthCount',
              detail: 'Reports created',
              icon: Icons.calendar_month_outlined,
              color: AppThemeDark.info,
            ),
            _SummaryCard(
              width: width,
              label: 'Latest report',
              value: latestReport,
              detail: reports.isNotEmpty ? 'Ready to download' : 'No entries',
              icon: Icons.check_circle_outline,
              color: AppThemeDark.success,
            ),
          ],
        );
      },
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
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
                  style: const TextStyle(color: AppThemeDark.textSecondary),
                ),
                const SizedBox(height: 8),
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

class _FilterMenu extends StatelessWidget {
  final ReportType? selected;
  final ValueChanged<ReportType?> onChanged;

  const _FilterMenu({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ReportType?>(
      value: selected,
      dropdownColor: AppThemeDark.secondary,
      underline: const SizedBox.shrink(),
      hint: const Text(
        'All reports',
        style: TextStyle(color: AppThemeDark.textWhite),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All reports')),
        DropdownMenuItem(
          value: ReportType.membership,
          child: Text('Membership'),
        ),
        DropdownMenuItem(value: ReportType.payments, child: Text('Payments')),
        DropdownMenuItem(value: ReportType.revenue, child: Text('Revenue')),
      ],
      onChanged: onChanged,
    );
  }
}

class _ReportsTable extends StatelessWidget {
  final List<ReportRecord> reports;
  final ValueChanged<ReportRecord> onDownload;
  final ValueChanged<int> onDelete;

  const _ReportsTable({
    required this.reports,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: reports.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No reports found in history.',
                  style: TextStyle(color: AppThemeDark.textSecondary),
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Report')),
                    DataColumn(label: Text('Period')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Format')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (final report in reports)
                      DataRow(
                        cells: [
                          DataCell(_ReportName(report: report)),
                          DataCell(Text(report.period)),
                          DataCell(Text(_formatDate(report.createdAt))),
                          DataCell(_FormatBadge(format: report.format)),
                          DataCell(_StatusBadge(status: report.status)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Download report',
                                  onPressed: () => onDownload(report),
                                  icon: const Icon(
                                    Icons.download_outlined,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete report',
                                  onPressed: () => onDelete(report.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
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
    );
  }
}

class _ReportName extends StatelessWidget {
  final ReportRecord report;

  const _ReportName({required this.report});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_iconForType(report.type), color: AppThemeDark.primary, size: 20),
        const SizedBox(width: 10),
        Text(report.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String format;

  const _FormatBadge({required this.format});

  @override
  Widget build(BuildContext context) {
    return Text(
      format,
      style: const TextStyle(color: AppThemeDark.textSecondary),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Text(status, style: const TextStyle(color: AppThemeDark.success));
  }
}

class _NewReportData {
  final String name;
  final ReportType type;
  final String period;
  final String format;

  const _NewReportData({
    required this.name,
    required this.type,
    required this.period,
    required this.format,
  });
}

class _GenerateReportDialog extends StatefulWidget {
  const _GenerateReportDialog();

  @override
  State<_GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<_GenerateReportDialog> {
  DateTime _start = DateTime(2026, 10, 1);
  DateTime _end = DateTime(2026, 10, 31);
  ReportType _type = ReportType.revenue;
  String _format = 'PDF';

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
        text: 'Generate report',
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
              text: 'Report type',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ReportType>(
              initialValue: _type,
              dropdownColor: AppThemeDark.secondary,
              style: const TextStyle(color: AppThemeDark.textWhite),
              iconEnabledColor: AppThemeDark.primary,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppThemeDark.secondary,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppThemeDark.borderPrimary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppThemeDark.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: ReportType.revenue,
                  child: Text('Revenue summary'),
                ),
                DropdownMenuItem(
                  value: ReportType.payments,
                  child: Text('Payments report'),
                ),
                DropdownMenuItem(
                  value: ReportType.membership,
                  child: Text('Membership overview'),
                ),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 14),
            const Text(
              'File format',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PDF', label: Text('PDF')),
                ButtonSegment(value: 'CSV', label: Text('CSV')),
              ],
              selected: {_format},
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
              onSelectionChanged: (selection) =>
                  setState(() => _format = selection.first),
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
          onPressed: () {
            Navigator.pop(
              context,
              _NewReportData(
                name: '${_typeLabel(_type)} - ${_formatDate(_start)}',
                type: _type,
                period: '${_formatDate(_start)} - ${_formatDate(_end)}',
                format: _format,
              ),
            );
          },
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
        side: BorderSide(color: AppThemeDark.borderPrimary),
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

IconData _iconForType(ReportType type) {
  return switch (type) {
    ReportType.membership => Icons.card_membership_outlined,
    ReportType.payments => Icons.receipt_long_outlined,
    ReportType.revenue => Icons.trending_up,
  };
}

String _typeLabel(ReportType type) {
  return switch (type) {
    ReportType.membership => 'Membership overview',
    ReportType.payments => 'Payments report',
    ReportType.revenue => 'Revenue summary',
  };
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
