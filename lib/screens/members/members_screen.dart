import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../providers/members_provider.dart';
import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../shared/widgets/custom_text_field.dart';
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
                _MembersToolbar(
                  controller: _searchController,
                  onSearchChanged: (value) {
                    ref.read(memberSearchQueryProvider.notifier).state = value
                        .trim();
                  },
                ),
                const SizedBox(height: 16),
                filteredMembersAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
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
                  data: (members) => _MembersTable(
                    members: members,
                    availableWidth: constraints.maxWidth,
                    onDelete: (id) =>
                        ref.read(membersProvider.notifier).deleteMember(id),
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
                '$memberCount members in your gym',
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

class _MembersToolbar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const _MembersToolbar({
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: GeneralSizes.mediumSize,
      runSpacing: GeneralSizes.mediumSize,
      children: [
        SizedBox(
          width: 280,
          child: CustomTextField(
            controller: controller,
            onFieldSubmitted: onSearchChanged,
            hintText: 'Search members',
            icon: HugeIcons.strokeRoundedSearch02,
            prefixCallBack: () {
              controller.clear();
              onSearchChanged('');
            },
          ),
        ),
        _ToolbarButton(label: 'Add New Membership', onPressed: () {}),
        _ToolbarButton(label: 'Renew Membership', onPressed: () {}),
        _ToolbarButton(label: 'Cancel Membership', onPressed: () {}),
        _ToolbarButton(label: 'View Expired', onPressed: () {}),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ToolbarButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppThemeDark.textWhite,
        side: BorderSide(color: AppThemeDark.primary.withValues(alpha: 0.6)),
      ),
      child: Text(label),
    );
  }
}

class _MembersTable extends StatelessWidget {
  final List<MemberDisplayModel> members;
  final double availableWidth;
  final ValueChanged<int> onDelete;

  const _MembersTable({
    required this.members,
    required this.availableWidth,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: availableWidth),
            child: DataTable(
              headingRowHeight: 52,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              horizontalMargin: 20,
              columnSpacing: 32,
              headingRowColor: WidgetStatePropertyAll(AppThemeDark.secondary),
              columns: [
                DataColumn(label: CustomText(text: 'Name')),
                DataColumn(label: CustomText(text: 'Age')),
                DataColumn(label: CustomText(text: 'Membership Type')),
                DataColumn(label: CustomText(text: 'Price')),
                DataColumn(label: CustomText(text: 'Status')),
                DataColumn(label: CustomText(text: 'Expiry Date')),
                DataColumn(label: CustomText(text: 'Actions')),
              ],
              rows: [
                for (final member in members)
                  DataRow(
                    color: WidgetStateProperty.resolveWith(
                      (states) => member.status.toLowerCase() == 'expired'
                          ? AppThemeDark.error.withValues(alpha: 0.16)
                          : null,
                    ),
                    cells: [
                      DataCell(CustomText(text: member.name)),
                      DataCell(CustomText(text: member.age.toString())),
                      DataCell(CustomText(text: member.membership)),
                      DataCell(
                        CustomText(
                          text: member.price == null
                              ? '-'
                              : member.price!.toStringAsFixed(2),
                        ),
                      ),
                      DataCell(_StatusLabel(status: member.status)),
                      DataCell(CustomText(text: member.expiryDate)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_outlined, size: 19),
                              tooltip: 'Edit member',
                            ),
                            IconButton(
                              onPressed: () => onDelete(member.id),
                              icon: const Icon(Icons.delete_outline, size: 19),
                              tooltip: 'Delete member',
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
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Text(
      status,
      style: TextStyle(
        color: isActive ? AppThemeDark.success : AppThemeDark.error,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
