import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/payment_provider.dart';
import '../database/db_init.dart';

enum ExcelReportSource { memberPayments, gymExpenses }

class GeneratedReportFile {
  final String filePath;
  final String fileName;
  final int recordCount;

  const GeneratedReportFile({
    required this.filePath,
    required this.fileName,
    required this.recordCount,
  });
}

class ExcelReportService {
  ExcelReportService._();

  static Future<GeneratedReportFile> generatePaymentsExcelReport({
    required ExcelReportSource source,
    required DateTime startDate,
    required DateTime endDate,
    required List<MemberPaymentRecord> allMemberPayments,
    required List<dynamic> allGymExpenses,
    bool includeSubscriptionHistory = false,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final excel = Excel.createExcel();
    final isPayments = source == ExcelReportSource.memberPayments;
    final mainSheetName = isPayments ? 'Member Payments' : 'Gym Expenses';

    // Rename default Sheet1
    excel.rename('Sheet1', mainSheetName);
    final sheet = excel[mainSheetName];

    final periodLabel = '${_formatDate(start)} - ${_formatDate(end)}';
    int recordCount = 0;

    if (isPayments) {
      final filtered = allMemberPayments.where((payment) {
        final d = DateTime(
          payment.date.year,
          payment.date.month,
          payment.date.day,
        );
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList();

      recordCount = filtered.length;
      _buildMemberPaymentsSheet(
        sheet: sheet,
        payments: filtered,
        periodLabel: periodLabel,
      );

      if (includeSubscriptionHistory) {
        await _buildSubscriptionHistorySheet(
          excel: excel,
          start: start,
          end: end,
        );
      }
    } else {
      final filtered = allGymExpenses.where((expense) {
        final d = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList();

      recordCount = filtered.length;
      _buildGymExpensesSheet(
        sheet: sheet,
        expenses: filtered,
        periodLabel: periodLabel,
      );
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel workbook.');
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory(p.join(docsDir.path, 'GymZero', 'Reports'));
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final prefix = isPayments ? 'member_payments' : 'gym_expenses';
    final timestamp = _fileTimestamp(DateTime.now());
    final fileName = '${prefix}_$timestamp.xlsx';
    final filePath = p.join(reportsDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return GeneratedReportFile(
      filePath: filePath,
      fileName: fileName,
      recordCount: recordCount,
    );
  }

  static void _buildMemberPaymentsSheet({
    required Sheet sheet,
    required List<MemberPaymentRecord> payments,
    required String periodLabel,
  }) {
    const headers = [
      '#',
      'Member Name',
      'Membership Plan',
      'Date',
      'Method',
      'Amount (\$)',
    ];

    _writeSheetBanner(
      sheet: sheet,
      title: 'Gym Zero - Member Payments Report',
      subtitle:
          'Period: $periodLabel  |  Generated: ${_formatDate(DateTime.now())}',
      columnCount: headers.length,
    );

    _writeHeaderRow(sheet: sheet, rowIndex: 3, headers: headers);

    final dataStartRow = 4;
    for (var i = 0; i < payments.length; i++) {
      final payment = payments[i];
      final rowIdx = dataStartRow + i;
      final isEven = i.isEven;

      _writeDataRow(
        sheet: sheet,
        rowIndex: rowIdx,
        isShaded: isEven,
        values: [
          IntCellValue(i + 1),
          TextCellValue(payment.memberName),
          TextCellValue(payment.membership),
          TextCellValue(_formatDate(payment.date)),
          TextCellValue(payment.method),
          DoubleCellValue(payment.amount),
        ],
        amountColumnIndex: 5,
      );
    }

    final totalRowIdx = dataStartRow + payments.length;
    _writeTotalRow(
      sheet: sheet,
      rowIndex: totalRowIdx,
      label: 'Total (${payments.length} transactions)',
      labelSpanEndCol: 4,
      amountCol: 5,
      excelAmountColLetter: 'F',
      firstDataExcelRow: dataStartRow + 1, // 1-indexed for Excel formulas
      lastDataExcelRow: dataStartRow + payments.length,
      hasData: payments.isNotEmpty,
    );

    // Column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 24);
    sheet.setColumnWidth(2, 22);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 16);
    sheet.setColumnWidth(5, 16);
  }

  static void _buildGymExpensesSheet({
    required Sheet sheet,
    required List<dynamic> expenses,
    required String periodLabel,
  }) {
    const headers = [
      '#',
      'Description',
      'Category',
      'Date',
      'Method',
      'Amount (\$)',
    ];

    _writeSheetBanner(
      sheet: sheet,
      title: 'Gym Zero - Gym Expenses Report',
      subtitle:
          'Period: $periodLabel  |  Generated: ${_formatDate(DateTime.now())}',
      columnCount: headers.length,
    );

    _writeHeaderRow(sheet: sheet, rowIndex: 3, headers: headers);

    final dataStartRow = 4;
    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final rowIdx = dataStartRow + i;
      final isEven = i.isEven;

      _writeDataRow(
        sheet: sheet,
        rowIndex: rowIdx,
        isShaded: isEven,
        values: [
          IntCellValue(i + 1),
          TextCellValue(expense.description),
          TextCellValue(expense.category),
          TextCellValue(_formatDate(expense.date)),
          TextCellValue(expense.method),
          DoubleCellValue(expense.amount),
        ],
        amountColumnIndex: 5,
      );
    }

    final totalRowIdx = dataStartRow + expenses.length;
    _writeTotalRow(
      sheet: sheet,
      rowIndex: totalRowIdx,
      label: 'Total (${expenses.length} expenses)',
      labelSpanEndCol: 4,
      amountCol: 5,
      excelAmountColLetter: 'F',
      firstDataExcelRow: dataStartRow + 1,
      lastDataExcelRow: dataStartRow + expenses.length,
      hasData: expenses.isNotEmpty,
    );

    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 16);
    sheet.setColumnWidth(5, 16);
  }

  static Future<void> _buildSubscriptionHistorySheet({
    required Excel excel,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await GymDatabase.instance.database;
    final startStr = _isoDate(start);
    final endStr = _isoDate(end);

    final rows = await db.rawQuery(
      '''
      SELECT
        m.name AS member_name,
        s.name AS plan_name,
        s.price AS price,
        sh.start_date,
        sh.end_date,
        sh.status
      FROM sub_history sh
      JOIN members m ON sh.member_id = m.member_id
      JOIN subs s ON sh.sub_id = s.sub_id
      WHERE sh.start_date >= ? AND sh.start_date <= ?
      ORDER BY sh.start_date DESC, sh.id DESC
    ''',
      [startStr, endStr],
    );

    final sheet = excel['Subscription History'];
    const headers = [
      'Member Name',
      'Plan',
      'Start Date',
      'End Date',
      'Status',
      'Price (\$)',
    ];

    _writeSheetBanner(
      sheet: sheet,
      title: 'Gym Zero - Member Subscription History',
      subtitle: 'Period: ${_formatDate(start)} - ${_formatDate(end)}',
      columnCount: headers.length,
    );

    _writeHeaderRow(sheet: sheet, rowIndex: 3, headers: headers);

    final dataStartRow = 4;
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      _writeDataRow(
        sheet: sheet,
        rowIndex: dataStartRow + i,
        isShaded: i.isEven,
        values: [
          TextCellValue((row['member_name'] as String?) ?? '-'),
          TextCellValue((row['plan_name'] as String?) ?? '-'),
          TextCellValue((row['start_date'] as String?) ?? '-'),
          TextCellValue((row['end_date'] as String?) ?? '-'),
          TextCellValue((row['status'] as String?) ?? '-'),
          DoubleCellValue(((row['price'] as num?) ?? 0).toDouble()),
        ],
        amountColumnIndex: 5,
      );
    }

    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 22);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 14);
    sheet.setColumnWidth(5, 16);
  }

  static void _writeSheetBanner({
    required Sheet sheet,
    required String title,
    required String subtitle,
    required int columnCount,
  }) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: columnCount - 1, rowIndex: 0),
      customValue: TextCellValue(title),
    );
    final titleCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 15,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E293B'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.setRowHeight(0, 28);

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: columnCount - 1, rowIndex: 1),
      customValue: TextCellValue(subtitle),
    );
    final subCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
    );
    subCell.cellStyle = CellStyle(
      italic: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#475569'),
      backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.setRowHeight(1, 20);
  }

  static void _writeHeaderRow({
    required Sheet sheet,
    required int rowIndex,
    required List<String> headers,
  }) {
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#334155'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }
    sheet.setRowHeight(rowIndex, 24);
  }

  static void _writeDataRow({
    required Sheet sheet,
    required int rowIndex,
    required bool isShaded,
    required List<CellValue> values,
    required int amountColumnIndex,
  }) {
    final bg = isShaded
        ? ExcelColor.fromHexString('#F8FAFC')
        : ExcelColor.white;

    for (var col = 0; col < values.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );
      cell.value = values[col];
      cell.cellStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: bg,
        horizontalAlign: col == amountColumnIndex
            ? HorizontalAlign.Right
            : HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        numberFormat: col == amountColumnIndex
            ? NumFormat
                  .standard_4 // #,##0.00
            : NumFormat.standard_0,
      );
    }
  }

  static void _writeTotalRow({
    required Sheet sheet,
    required int rowIndex,
    required String label,
    required int labelSpanEndCol,
    required int amountCol,
    required String excelAmountColLetter,
    required int firstDataExcelRow,
    required int lastDataExcelRow,
    required bool hasData,
  }) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: labelSpanEndCol,
        rowIndex: rowIndex,
      ),
      customValue: TextCellValue(label),
    );

    final totalStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#0F172A'),
      backgroundColorHex: ExcelColor.fromHexString('#E2E8F0'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );

    sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .cellStyle =
        totalStyle;

    final amountCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: amountCol, rowIndex: rowIndex),
    );
    amountCell.value = hasData
        ? FormulaCellValue(
            'SUM($excelAmountColLetter$firstDataExcelRow:$excelAmountColLetter$lastDataExcelRow)',
          )
        : DoubleCellValue(0.0);
    amountCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#0F172A'),
      backgroundColorHex: ExcelColor.fromHexString('#E2E8F0'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: NumFormat.standard_4,
    );
    sheet.setRowHeight(rowIndex, 24);
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _fileTimestamp(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}_'
      '${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}${dt.second.toString().padLeft(2, '0')}';
}
