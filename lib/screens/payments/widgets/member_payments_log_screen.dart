import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../providers/payment_provider.dart';
import '../../../shared/constants/general_sizes.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';

class MemberPaymentsLogScreen extends ConsumerStatefulWidget {
  const MemberPaymentsLogScreen({super.key});

  @override
  ConsumerState<MemberPaymentsLogScreen> createState() =>
      _MemberPaymentsLogScreenState();
}

class _MemberPaymentsLogScreenState
    extends ConsumerState<MemberPaymentsLogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMethod = 'All';

  static const _methods = ['All', 'Cash', 'Card', 'Bank transfer'];

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
          'Member Payments Log',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
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
              text: 'Failed to load member payments: $err',
              color: AppThemeDark.error,
            ),
          ),
        ),
        data: (data) {
          final filtered = data.memberPayments.where((payment) {
            final matchesMethod =
                _selectedMethod == 'All' ||
                payment.method.toLowerCase() == _selectedMethod.toLowerCase();
            if (!matchesMethod) return false;
            if (_searchQuery.isEmpty) return true;

            final formattedDate = _formatDate(payment.date);
            return payment.memberName.toLowerCase().contains(_searchQuery) ||
                payment.membership.toLowerCase().contains(_searchQuery) ||
                payment.method.toLowerCase().contains(_searchQuery) ||
                formattedDate.contains(_searchQuery);
          }).toList();

          final filteredTotal = filtered.fold<double>(
            0.0,
            (sum, p) => sum + p.amount,
          );

          return Padding(
            padding: const EdgeInsets.all(GeneralSizes.largeSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar + method filter chips
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
                        hintText: 'Search by member, plan, method, or date...',
                        icon: HugeIcons.strokeRoundedSearch02,
                        prefixCallBack: () => _searchController.clear(),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final method in _methods)
                          ChoiceChip(
                            label: Text(method),
                            selected: _selectedMethod == method,
                            onSelected: (_) =>
                                setState(() => _selectedMethod = method),
                            backgroundColor: AppThemeDark.secondary,
                            selectedColor: AppThemeDark.primary,
                            labelStyle: TextStyle(
                              color: _selectedMethod == method
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
                      'Showing ${filtered.length} of ${data.memberPayments.length} transactions',
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Total: +${_formatCurrency(filteredTotal)}',
                      style: const TextStyle(
                        color: AppThemeDark.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Scrollable log list
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyLogCard(
                          message:
                              _searchQuery.isEmpty && _selectedMethod == 'All'
                              ? 'No member payments recorded yet.'
                              : 'No payments match your search or filter.',
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
                            separatorBuilder: (_, __) => Divider(
                              color: AppThemeDark.borderPrimary.withValues(
                                alpha: 0.5,
                              ),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final payment = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppThemeDark.primary
                                          .withValues(alpha: 0.12),
                                      child: Icon(
                                        Icons.person,
                                        color: AppThemeDark.primary,
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
                                    _MethodChip(method: payment.method),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => ref
                                          .read(paymentsProvider.notifier)
                                          .deletePayment(payment.paymentId),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                      color: AppThemeDark.textSecondary,
                                      tooltip: 'Delete transaction',
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

class _EmptyLogCard extends StatelessWidget {
  final String message;

  const _EmptyLogCard({required this.message});

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
