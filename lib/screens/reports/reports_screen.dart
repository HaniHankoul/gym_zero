import 'package:flutter/material.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';

enum _ReportType { membership, payments, revenue }

class _ReportRecord {
  final String name;
  final _ReportType type;
  final DateTime createdAt;
  final String period;
  final String format;
  final String status;

  const _ReportRecord({
    required this.name,
    required this.type,
    required this.createdAt,
    required this.period,
    required this.format,
    required this.status,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<_ReportRecord> _reports = [
    _ReportRecord(
      name: 'September revenue summary',
      type: _ReportType.revenue,
      createdAt: DateTime(2026, 9, 30, 16, 20),
      period: '01 Sep - 30 Sep 2026',
      format: 'PDF',
      status: 'Ready',
    ),
    _ReportRecord(
      name: 'September payments report',
      type: _ReportType.payments,
      createdAt: DateTime(2026, 9, 28, 10, 5),
      period: '01 Sep - 30 Sep 2026',
      format: 'CSV',
      status: 'Ready',
    ),
    _ReportRecord(
      name: 'Active memberships overview',
      type: _ReportType.membership,
      createdAt: DateTime(2026, 9, 15, 9, 40),
      period: '01 Sep - 15 Sep 2026',
      format: 'PDF',
      status: 'Ready',
    ),
    _ReportRecord(
      name: 'August revenue summary',
      type: _ReportType.revenue,
      createdAt: DateTime(2026, 8, 31, 14, 15),
      period: '01 Aug - 31 Aug 2026',
      format: 'PDF',
      status: 'Ready',
    ),
  ];

  _ReportType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final visibleReports = _selectedFilter == null
        ? _reports
        : _reports.where((report) => report.type == _selectedFilter).toList();

    return Container(
      color: AppThemeDark.primaryBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeneralSizes.largeSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(onGenerate: _showGenerateDialog),
            const SizedBox(height: 24),
            _SummaryRow(reportCount: _reports.length),
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
                  selected: _selectedFilter,
                  onChanged: (value) => setState(() => _selectedFilter = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ReportsTable(
              reports: visibleReports,
              onDownload: (report) =>
                  _showMessage('${report.name} downloaded.'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGenerateDialog() async {
    final report = await showDialog<_ReportRecord>(
      context: context,
      builder: (context) => const _GenerateReportDialog(),
    );
    if (!mounted || report == null) return;
    setState(() => _reports.insert(0, report));
    _showMessage('${report.name} is ready.');
  }

  void _showMessage(String message) {
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
          icon: const Icon(Icons.assessment_outlined, size: 18),
          label: const Text('Generate report'),
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
  final int reportCount;

  const _SummaryRow({required this.reportCount});

  @override
  Widget build(BuildContext context) {
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
              value: '$reportCount',
              detail: 'Generated reports',
              icon: Icons.description_outlined,
              color: AppThemeDark.primary,
            ),
            _SummaryCard(
              width: width,
              label: 'This month',
              value: '3',
              detail: 'Reports created',
              icon: Icons.calendar_month_outlined,
              color: AppThemeDark.info,
            ),
            _SummaryCard(
              width: width,
              label: 'Latest report',
              value: 'Today',
              detail: 'Ready to download',
              icon: Icons.check_circle_outline,
              color: AppThemeDark.success,
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
  final _ReportType? selected;
  final ValueChanged<_ReportType?> onChanged;

  const _FilterMenu({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<_ReportType?>(
      value: selected,
      dropdownColor: AppThemeDark.secondary,
      underline: const SizedBox.shrink(),
      hint: const Text('All reports'),
      items: const [
        DropdownMenuItem(value: null, child: Text('All reports')),
        DropdownMenuItem(
          value: _ReportType.membership,
          child: Text('Membership'),
        ),
        DropdownMenuItem(value: _ReportType.payments, child: Text('Payments')),
        DropdownMenuItem(value: _ReportType.revenue, child: Text('Revenue')),
      ],
      onChanged: onChanged,
    );
  }
}

class _ReportsTable extends StatelessWidget {
  final List<_ReportRecord> reports;
  final ValueChanged<_ReportRecord> onDownload;

  const _ReportsTable({required this.reports, required this.onDownload});

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
                  'No reports found for this category.',
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
                    DataColumn(label: Text('')),
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
                            IconButton(
                              tooltip: 'Download report',
                              onPressed: () => onDownload(report),
                              icon: const Icon(Icons.download_outlined),
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
  final _ReportRecord report;

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

class _GenerateReportDialog extends StatefulWidget {
  const _GenerateReportDialog();

  @override
  State<_GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<_GenerateReportDialog> {
  DateTime _start = DateTime(2026, 10, 1);
  DateTime _end = DateTime(2026, 10, 31);
  _ReportType _type = _ReportType.revenue;
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
      title: const Text('Generate report'),
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
              'Report type',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<_ReportType>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(
                  value: _ReportType.revenue,
                  child: Text('Revenue summary'),
                ),
                DropdownMenuItem(
                  value: _ReportType.payments,
                  child: Text('Payments report'),
                ),
                DropdownMenuItem(
                  value: _ReportType.membership,
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
              onSelectionChanged: (selection) =>
                  setState(() => _format = selection.first),
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
          onPressed: _generate,
          child: const Text('Generate report'),
        ),
      ],
    );
  }

  void _generate() {
    Navigator.pop(
      context,
      _ReportRecord(
        name: '${_typeLabel(_type)} - ${_formatDate(_start)}',
        type: _type,
        createdAt: DateTime(2026, 10, 31, 11, 30),
        period: '${_formatDate(_start)} - ${_formatDate(_end)}',
        format: _format,
        status: 'Ready',
      ),
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

IconData _iconForType(_ReportType type) {
  return switch (type) {
    _ReportType.membership => Icons.card_membership_outlined,
    _ReportType.payments => Icons.receipt_long_outlined,
    _ReportType.revenue => Icons.trending_up,
  };
}

String _typeLabel(_ReportType type) {
  return switch (type) {
    _ReportType.membership => 'Membership overview',
    _ReportType.payments => 'Payments report',
    _ReportType.revenue => 'Revenue summary',
  };
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
