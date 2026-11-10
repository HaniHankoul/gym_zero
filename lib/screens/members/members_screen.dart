import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../providers/members_provider.dart';
import 'widgets/add_member_dialog.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddMemberDialog() async {
    final payload = await showDialog<NewMemberPayload>(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );
    if (!mounted || payload == null) return;

    await ref
        .read(membersProvider.notifier)
        .addMemberWithSubscription(
          name: payload.name,
          age: payload.age,
          durationMonths: payload.durationMonths,
          price: payload.price,
        );
  }

  void _showMemberDetails(MemberDisplayModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MemberDetailsSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembersAsync = ref.watch(filteredMembersProvider);

    return Container(
      color: AppThemeDark.primaryBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(GeneralSizes.largeSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MembersHeader(
                  memberCount: filteredMembersAsync.value?.length ?? 0,
                  onAddMember: _showAddMemberDialog,
                ),
                const SizedBox(height: 24),
                // Search bar only: No toolbar buttons
                SizedBox(
                  width: constraints.maxWidth < 600 ? double.infinity : 360,
                  child: CustomTextField(
                    controller: _searchController,
                    onFieldSubmitted: (value) {
                      ref.read(memberSearchQueryProvider.notifier).state = value
                          .trim();
                    },
                    hintText: 'Search by member name...',
                    icon: HugeIcons.strokeRoundedSearch02,
                    prefixCallBack: () {
                      _searchController.clear();
                      ref.read(memberSearchQueryProvider.notifier).state = '';
                    },
                  ),
                ),
                const SizedBox(height: 20),
                filteredMembersAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CustomText(
                        text: 'Failed to load members: $err',
                        color: AppThemeDark.error,
                      ),
                    ),
                  ),
                  data: (members) {
                    if (members.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppThemeDark.secondary,
                          borderRadius: BorderRadius.circular(
                            GeneralSizes.borderRadiusM,
                          ),
                          border: Border.all(color: AppThemeDark.borderPrimary),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 48,
                              color: AppThemeDark.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No members found',
                              style: TextStyle(
                                color: AppThemeDark.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _MembersCardGrid(
                      members: members,
                      onMemberTap: _showMemberDetails,
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
}

class _MembersHeader extends StatelessWidget {
  final int memberCount;
  final VoidCallback onAddMember;

  const _MembersHeader({required this.memberCount, required this.onAddMember});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Members',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppThemeDark.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$memberCount members registered in gym',
                style: const TextStyle(color: AppThemeDark.textSecondary),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onAddMember,
          icon: const Icon(
            Icons.person_add_alt_1,
            size: 18,
            color: Colors.black,
          ),
          label: const Text(
            'Add member',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppThemeDark.primary,
            foregroundColor: AppThemeDark.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _MembersCardGrid extends StatelessWidget {
  final List<MemberDisplayModel> members;
  final ValueChanged<MemberDisplayModel> onMemberTap;

  const _MembersCardGrid({required this.members, required this.onMemberTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 680
            ? 1
            : constraints.maxWidth < 1100
            ? 2
            : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 148,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isActive = member.status.toLowerCase() == 'active';

            return InkWell(
              onTap: () => onMemberTap(member),
              borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeDark.secondary,
                  borderRadius: BorderRadius.circular(
                    GeneralSizes.borderRadiusM,
                  ),
                  border: Border.all(
                    color: isActive
                        ? AppThemeDark.borderPrimary
                        : AppThemeDark.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppThemeDark.primary.withValues(
                            alpha: 0.14,
                          ),
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : 'M',
                            style: TextStyle(
                              color: AppThemeDark.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppThemeDark.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Age: ${member.age}',
                                style: const TextStyle(
                                  color: AppThemeDark.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(status: member.status),
                      ],
                    ),
                    const Spacer(),
                    Divider(
                      color: AppThemeDark.borderPrimary.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.card_membership,
                              size: 15,
                              color: AppThemeDark.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              member.membership,
                              style: const TextStyle(
                                color: AppThemeDark.textWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          member.expiryDate != '-'
                              ? 'Exp: ${member.expiryDate}'
                              : 'No expiry',
                          style: const TextStyle(
                            color: AppThemeDark.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MemberDetailsSheet extends ConsumerWidget {
  final MemberDisplayModel member;

  const _MemberDetailsSheet({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = member.status.toLowerCase() == 'active';

    return Container(
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeDark.borderPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppThemeDark.primary.withValues(
                      alpha: 0.16,
                    ),
                    child: Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : 'M',
                      style: TextStyle(
                        color: AppThemeDark.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            color: AppThemeDark.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member ID: #${member.id} • ${member.age} years old',
                          style: const TextStyle(
                            color: AppThemeDark.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: member.status),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppThemeDark.borderPrimary),
              const SizedBox(height: 16),
              // Subscription details info
              const Text(
                'Subscription Information',
                style: TextStyle(
                  color: AppThemeDark.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'Plan', value: member.membership),
              _DetailRow(
                label: 'Price',
                value: member.price != null
                    ? '\$${member.price!.toStringAsFixed(2)}'
                    : 'N/A',
              ),
              _DetailRow(label: 'Expiry Date', value: member.expiryDate),
              _DetailRow(label: 'Status', value: member.status),
              const SizedBox(height: 28),
              // Action Buttons
              const Text(
                'Actions',
                style: TextStyle(
                  color: AppThemeDark.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (!isActive)
                    FilledButton.icon(
                      onPressed: () => _showAddSubscriptionDialog(context, ref),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 18,
                      ),
                      label: const Text(
                        'Add Subscription',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppThemeDark.primary,
                      ),
                    ),
                  if (isActive) ...[
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showEditSubscriptionDialog(context, ref),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Subscription'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeDark.textWhite,
                        side: const BorderSide(
                          color: AppThemeDark.borderPrimary,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmCancelSubscription(context, ref),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Subscription'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeDark.warning,
                        side: BorderSide(
                          color: AppThemeDark.warning.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _confirmDeleteMember(context, ref),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete Member'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeDark.error,
                      side: BorderSide(
                        color: AppThemeDark.error.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context, WidgetRef ref) {
    final durationController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeDark.secondary,
        title: const Text(
          'Add Subscription',
          style: TextStyle(color: AppThemeDark.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: durationController,
              hintText: 'Duration (months)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: priceController,
              hintText: 'Price (\$)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final duration = int.tryParse(durationController.text.trim());
              final price = double.tryParse(
                priceController.text.trim().replaceAll(',', '.'),
              );
              if (duration == null || duration <= 0) return;

              await ref
                  .read(membersProvider.notifier)
                  .addOrRenewSubscription(
                    memberId: member.id,
                    durationMonths: duration,
                    price: price ?? 0.0,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeDark.primary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showEditSubscriptionDialog(BuildContext context, WidgetRef ref) {
    if (member.subId == null || member.subHistoryId == null) return;

    final durationController = TextEditingController();
    final priceController = TextEditingController(
      text: member.price?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeDark.secondary,
        title: const Text(
          'Edit Subscription',
          style: TextStyle(color: AppThemeDark.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: durationController,
              hintText: 'New Duration (months from today)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: priceController,
              hintText: 'Updated Price (\$)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final duration = int.tryParse(durationController.text.trim());
              final price = double.tryParse(
                priceController.text.trim().replaceAll(',', '.'),
              );
              if (duration == null || duration <= 0) return;

              await ref
                  .read(membersProvider.notifier)
                  .editSubscription(
                    subId: member.subId!,
                    subHistoryId: member.subHistoryId!,
                    durationMonths: duration,
                    price: price ?? (member.price ?? 0.0),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeDark.primary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _confirmCancelSubscription(BuildContext context, WidgetRef ref) {
    if (member.subHistoryId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeDark.secondary,
        title: const Text(
          'Cancel Subscription',
          style: TextStyle(color: AppThemeDark.textWhite),
        ),
        content: const Text(
          'Are you sure you want to cancel this active subscription? The status will be updated to Cancelled.',
          style: TextStyle(color: AppThemeDark.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(membersProvider.notifier)
                  .cancelSubscription(member.subHistoryId!);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeDark.warning,
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMember(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeDark.secondary,
        title: const Text(
          'Delete Member',
          style: TextStyle(color: AppThemeDark.textWhite),
        ),
        content: Text(
          'Are you sure you want to delete ${member.name}? This will permanently remove all associated subscription and attendance records.',
          style: const TextStyle(color: AppThemeDark.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(membersProvider.notifier).deleteMember(member.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppThemeDark.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppThemeDark.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppThemeDark.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final color = lower == 'active'
        ? AppThemeDark.success
        : lower == 'cancelled'
        ? AppThemeDark.warning
        : AppThemeDark.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
