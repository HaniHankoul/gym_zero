import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../providers/payment_provider.dart';
import '../../../shared/constants/general_sizes.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../payments_screen.dart';

class GymExpensesLogScreen extends ConsumerStatefulWidget {
  const GymExpensesLogScreen({super.key});

  @override
  ConsumerState<GymExpensesLogScreen> createState() =>
      _GymExpensesLogScreenState();
}

class _GymExpensesLogScreenState extends ConsumerState<GymExpensesLogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Facility',
    'Equipment',
    'Maintenance',
    'Utilities',
    'Supplies',
    'Salaries',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchUpdated);
  }

  void _onSearchUpdated() {
    final next = _searchController.text.trim().toLowerCase();
    if (next != _searchQuery) {
      setState(() => _searchQuery = next);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchUpdated);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      backgroundColor: AppThemeDark.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppThemeDark.secondary,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppThemeDark.textWhite,
        elevation: 0,
        title: const Text(
          'Gym Expenses Log',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => showAddExpenseDialog(context, ref),
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
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppThemeDark.borderPrimary),
        ),
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomText(
              text: 'Failed to load gym expenses: $err',
              color: AppThemeDark.error,
            ),
          ),
        ),
        data: (data) {
          final filtered = data.gymExpenses.where((expense) {
            final matchesCategory =
                _selectedCategory == 'All' ||
                expense.category.toLowerCase() ==
                    _selectedCategory.toLowerCase();
            if (!matchesCategory) return false;
            if (_searchQuery.isEmpty) return true;

            final formattedDate = _formatDate(expense.date);
            return expense.description.toLowerCase().contains(_searchQuery) ||
                expense.category.toLowerCase().contains(_searchQuery) ||
                expense.method.toLowerCase().contains(_searchQuery) ||
                formattedDate.contains(_searchQuery);
          }).toList();

          final filteredTotal = filtered.fold<double>(
            0.0,
            (sum, e) => sum + e.amount,
          );

          return Padding(
            padding: const EdgeInsets.all(GeneralSizes.largeSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar + category filter chips
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 340,
                      child: CustomTextField(
                        controller: _searchController,
                        onFieldSubmitted: (_) => _onSearchUpdated(),
                        hintText: 'Search by description, category, method, or date...',
                        icon: HugeIcons.strokeRoundedSearch02,
                        prefixCallBack: () => _searchController.clear(),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final category in _categories)
                          ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = category),
                            backgroundColor: AppThemeDark.secondary,
                            selectedColor: AppThemeDark.primary,
                            labelStyle: TextStyle(
                              color: _selectedCategory == category
                                  ? Colors.black
                                  : AppThemeDark.textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            side: const BorderSide(
                              color: AppThemeDark.borderPrimary,
                            ),
                            showCheckmark: false,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Result count + filtered subtotal bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${filtered.length} of ${data.gymExpenses.length} expenses',
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Total: -${_formatCurrency(filteredTotal)}',
                      style: const TextStyle(
                        color: AppThemeDark.warning,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Scrollable expense list
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyExpenseCard(
                          message:
                              _searchQuery.isEmpty && _selectedCategory == 'All'
                              ? 'No gym expenses recorded yet.'
                              : 'No expenses match your search or category.',
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppThemeDark.secondary,
                            borderRadius: BorderRadius.circular(
                              GeneralSizes.borderRadiusM,
                            ),
                            border: Border.all(
                              color: AppThemeDark.borderPrimary,
                            ),
                          ),
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => Divider(
                              color: AppThemeDark.borderPrimary.withValues(
                                alpha: 0.5,
                              ),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final expense = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppThemeDark.warning
                                          .withValues(alpha: 0.12),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: AppThemeDark.warning,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                    _MethodChip(method: expense.method),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => ref
                                          .read(paymentsProvider.notifier)
                                          .deleteExpense(expense.id),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                      color: AppThemeDark.textSecondary,
                                      tooltip: 'Delete expense',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String method;

  const _MethodChip({required this.method});

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

class _EmptyExpenseCard extends StatelessWidget {
  final String message;

  const _EmptyExpenseCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
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

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';
