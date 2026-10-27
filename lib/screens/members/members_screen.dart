import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../shared/widgets/custom_text_field.dart';

class MemberRecord {
  final String name;
  final String membership;
  final String status;
  final String expiryDate;

  const MemberRecord({
    required this.name,
    required this.membership,
    required this.status,
    required this.expiryDate,
  });
}

const _members = [
  MemberRecord(
    name: 'John Smith',
    membership: 'Gold',
    status: 'Active',
    expiryDate: '2024-12-31',
  ),
  MemberRecord(
    name: 'Edmar Johnson',
    membership: 'Silver',
    status: 'Active',
    expiryDate: '2024-12-31',
  ),
  MemberRecord(
    name: 'Maria Pime',
    membership: 'Silver',
    status: 'Active',
    expiryDate: '2024-12-31',
  ),
  MemberRecord(
    name: 'Maria Garcia',
    membership: 'Silver',
    status: 'Expired',
    expiryDate: '2023-11-15',
  ),
  MemberRecord(
    name: 'Ranny Smith',
    membership: 'Gold',
    status: 'Active',
    expiryDate: '2024-12-31',
  ),
  MemberRecord(
    name: 'Alhan Game',
    membership: 'Silver',
    status: 'Active',
    expiryDate: '2024-11-15',
  ),
  MemberRecord(
    name: 'Denna Smith',
    membership: 'Silver',
    status: 'Active',
    expiryDate: '2024-12-31',
  ),
];

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _members
        .where((member) => member.name.toLowerCase().contains(_searchQuery))
        .toList();

    return Container(
      color: AppThemeDark.primaryBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(GeneralSizes.largeSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MembersHeader(memberCount: filteredMembers.length),
                const SizedBox(height: 24),
                _MembersToolbar(
                  controller: _searchController,
                  onSearchChanged: (value) {
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  },
                ),
                const SizedBox(height: 16),
                _MembersTable(
                  members: filteredMembers,
                  availableWidth: constraints.maxWidth,
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

  const _MembersHeader({required this.memberCount});

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
          onPressed: () {},
          icon: const Icon(Icons.person_add_alt_1, size: 18),
          label: const Text('Add member'),
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
          // child: TextField(
          //   controller: controller,
          //   onChanged: onSearchChanged,
          //   style: const TextStyle(color: AppThemeDark.textWhite),
          //   decoration: InputDecoration(
          //     hintText: 'Search members',
          //     prefixIcon: const Icon(Icons.search),
          //     suffixIcon: controller.text.isNotEmpty
          //         ? IconButton(
          //             onPressed: () {
          //               controller.clear();
          //               onSearchChanged('');
          //             },
          //             icon: const Icon(Icons.close),
          //             tooltip: 'Clear search',
          //           )
          //         : null,
          //   ),
          // ),
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
  final List<MemberRecord> members;
  final double availableWidth;

  const _MembersTable({required this.members, required this.availableWidth});

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
                DataColumn(label: CustomText(text: 'Membership Type')),
                DataColumn(label: CustomText(text: 'Status')),
                DataColumn(label: CustomText(text: 'Expiry Date')),
                DataColumn(label: CustomText(text: 'Actions')),
              ],
              rows: [
                for (final member in members)
                  DataRow(
                    color: WidgetStateProperty.resolveWith(
                      (states) => member.status == 'Expired'
                          ? AppThemeDark.error.withValues(alpha: 0.16)
                          : null,
                    ),
                    cells: [
                      DataCell(Text(member.name)),
                      DataCell(Text(member.membership)),
                      DataCell(_StatusLabel(status: member.status)),
                      DataCell(Text(member.expiryDate)),
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
                              onPressed: () {},
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
    final isActive = status == 'Active';
    return Text(
      status,
      style: TextStyle(
        color: isActive ? AppThemeDark.success : AppThemeDark.error,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
