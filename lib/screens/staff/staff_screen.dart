import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/custom_text.dart';
import '../../shared/widgets/custom_text_field.dart';

enum _StaffTab { staff, receptionists }

enum _StaffRole {
  trainer('Trainer'),
  receptionist('Receptionist'),
  manager('Manager'),
  maintenance('Maintenance');

  final String label;
  const _StaffRole(this.label);
}

class _StaffAttendanceRecord {
  final DateTime date;
  final String checkIn;
  final String? checkOut;
  final String status;

  const _StaffAttendanceRecord({
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.status,
  });

  _StaffAttendanceRecord copyWith({String? checkOut, String? status}) {
    return _StaffAttendanceRecord(
      date: date,
      checkIn: checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
    );
  }
}

class _StaffMember {
  final int id;
  final String name;
  final _StaffRole role;
  final String phone;
  final String shift;
  final double salary;
  final bool isCheckedInToday;
  final List<_StaffAttendanceRecord> attendanceLog;

  const _StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.shift,
    required this.salary,
    required this.isCheckedInToday,
    required this.attendanceLog,
  });

  _StaffMember copyWith({
    bool? isCheckedInToday,
    List<_StaffAttendanceRecord>? attendanceLog,
  }) {
    return _StaffMember(
      id: id,
      name: name,
      role: role,
      phone: phone,
      shift: shift,
      salary: salary,
      isCheckedInToday: isCheckedInToday ?? this.isCheckedInToday,
      attendanceLog: attendanceLog ?? this.attendanceLog,
    );
  }
}

class _RegisteredMemberPreview {
  final String name;
  final String plan;
  final String status;
  final String joinedDate;

  const _RegisteredMemberPreview({
    required this.name,
    required this.plan,
    required this.status,
    required this.joinedDate,
  });
}

class _ReceptionistAccount {
  final int userId;
  final String username;
  final String fullName;
  final String shift;
  final bool isActive;
  final List<_RegisteredMemberPreview> members;

  const _ReceptionistAccount({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.shift,
    required this.isActive,
    required this.members,
  });
}

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _StaffTab _activeTab = _StaffTab.staff;
  _StaffRole? _selectedRole;

  late List<_StaffMember> _staffList;
  late List<_ReceptionistAccount> _receptionistAccounts;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    _staffList = [
      _StaffMember(
        id: 1,
        name: 'Tariq Mansour',
        role: _StaffRole.trainer,
        phone: '+963 944 120 340',
        shift: 'Morning (07:00 - 15:00)',
        salary: 650,
        isCheckedInToday: true,
        attendanceLog: [
          _StaffAttendanceRecord(
            date: today,
            checkIn: '06:55',
            status: 'Present',
          ),
          _StaffAttendanceRecord(
            date: yesterday,
            checkIn: '07:02',
            checkOut: '15:05',
            status: 'Present',
          ),
          _StaffAttendanceRecord(
            date: twoDaysAgo,
            checkIn: '07:18',
            checkOut: '15:00',
            status: 'Late',
          ),
        ],
      ),
      _StaffMember(
        id: 2,
        name: 'Lina Haddad',
        role: _StaffRole.receptionist,
        phone: '+963 933 812 450',
        shift: 'Morning (08:00 - 16:00)',
        salary: 480,
        isCheckedInToday: true,
        attendanceLog: [
          _StaffAttendanceRecord(
            date: today,
            checkIn: '07:54',
            status: 'Present',
          ),
          _StaffAttendanceRecord(
            date: yesterday,
            checkIn: '08:00',
            checkOut: '16:03',
            status: 'Present',
          ),
        ],
      ),
      _StaffMember(
        id: 3,
        name: 'Omar Al-Khatib',
        role: _StaffRole.receptionist,
        phone: '+963 955 601 229',
        shift: 'Evening (16:00 - 00:00)',
        salary: 480,
        isCheckedInToday: false,
        attendanceLog: [
          _StaffAttendanceRecord(
            date: yesterday,
            checkIn: '15:58',
            checkOut: '23:55',
            status: 'Present',
          ),
          _StaffAttendanceRecord(
            date: twoDaysAgo,
            checkIn: '16:22',
            checkOut: '00:02',
            status: 'Late',
          ),
        ],
      ),
      _StaffMember(
        id: 4,
        name: 'Sami Darwish',
        role: _StaffRole.trainer,
        phone: '+963 966 310 908',
        shift: 'Evening (15:00 - 23:00)',
        salary: 700,
        isCheckedInToday: false,
        attendanceLog: [
          _StaffAttendanceRecord(
            date: yesterday,
            checkIn: '14:55',
            checkOut: '23:00',
            status: 'Present',
          ),
        ],
      ),
      _StaffMember(
        id: 5,
        name: 'Khaled Nassar',
        role: _StaffRole.maintenance,
        phone: '+963 941 772 015',
        shift: 'Morning (07:00 - 14:00)',
        salary: 400,
        isCheckedInToday: true,
        attendanceLog: [
          _StaffAttendanceRecord(
            date: today,
            checkIn: '07:10',
            status: 'Present',
          ),
          _StaffAttendanceRecord(
            date: yesterday,
            checkIn: '07:00',
            checkOut: '14:00',
            status: 'Present',
          ),
        ],
      ),
    ];

    _receptionistAccounts = [
      const _ReceptionistAccount(
        userId: 1,
        username: 'lina.desk',
        fullName: 'Lina Haddad',
        shift: 'Morning (08:00 - 16:00)',
        isActive: true,
        members: [
          _RegisteredMemberPreview(
            name: 'Ahmad Al-Masri',
            plan: '3 Months Plan',
            status: 'Active',
            joinedDate: '2026-11-18',
          ),
          _RegisteredMemberPreview(
            name: 'Nour Al-Din',
            plan: '1 Month Plan',
            status: 'Active',
            joinedDate: '2026-11-12',
          ),
          _RegisteredMemberPreview(
            name: 'Rami Saleh',
            plan: '6 Months Plan',
            status: 'Expired',
            joinedDate: '2026-04-20',
          ),
        ],
      ),
      const _ReceptionistAccount(
        userId: 2,
        username: 'omar.night',
        fullName: 'Omar Al-Khatib',
        shift: 'Evening (16:00 - 00:00)',
        isActive: true,
        members: [
          _RegisteredMemberPreview(
            name: 'Youssef Kassem',
            plan: '12 Months Plan',
            status: 'Active',
            joinedDate: '2026-10-05',
          ),
          _RegisteredMemberPreview(
            name: 'Maya Khoury',
            plan: '3 Months Plan',
            status: 'Cancelled',
            joinedDate: '2026-09-14',
          ),
        ],
      ),
      const _ReceptionistAccount(
        userId: 3,
        username: 'admin',
        fullName: 'Main Admin Account',
        shift: 'All Shifts',
        isActive: true,
        members: [
          _RegisteredMemberPreview(
            name: 'Zaid Barakat',
            plan: '1 Month Plan',
            status: 'Active',
            joinedDate: '2026-11-22',
          ),
        ],
      ),
    ];
  }

  void _onSearchChanged() {
    final next = _searchController.text.trim().toLowerCase();
    if (next != _searchQuery) {
      setState(() => _searchQuery = next);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _toggleStaffAttendance(int staffId) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      final index = _staffList.indexWhere((s) => s.id == staffId);
      if (index == -1) return;

      final staff = _staffList[index];
      final updatedLogs = List<_StaffAttendanceRecord>.from(
        staff.attendanceLog,
      );

      if (staff.isCheckedInToday) {
        if (updatedLogs.isNotEmpty && updatedLogs.first.checkOut == null) {
          updatedLogs[0] = updatedLogs[0].copyWith(checkOut: timeStr);
        }
        _staffList[index] = staff.copyWith(
          isCheckedInToday: false,
          attendanceLog: updatedLogs,
        );
      } else {
        updatedLogs.insert(
          0,
          _StaffAttendanceRecord(
            date: now,
            checkIn: timeStr,
            status: 'Present',
          ),
        );
        _staffList[index] = staff.copyWith(
          isCheckedInToday: true,
          attendanceLog: updatedLogs,
        );
      }
    });
  }

  void _deleteStaff(int staffId) {
    setState(() {
      _staffList.removeWhere((s) => s.id == staffId);
    });
  }

  Future<void> _showAddStaffDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final shiftController = TextEditingController(
      text: 'Morning (08:00 - 16:00)',
    );
    final salaryController = TextEditingController();
    var selectedRole = _StaffRole.trainer;

    final created = await showDialog<_StaffMember>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppThemeDark.secondary,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppThemeDark.borderPrimary),
          ),
          title: CustomText(
            text: 'Add Staff Member',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      autofocus: true,
                      hintText: 'Full name',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Role',
                      style: TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<_StaffRole>(
                      value: selectedRole,
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
                      items: _StaffRole.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRole = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Phone number',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter phone number'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: shiftController,
                      hintText: 'Shift (e.g. Morning 08:00 - 16:00)',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter shift' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: salaryController,
                      hintText: 'Monthly salary (\$)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final parsed = double.tryParse(
                          (v ?? '').trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid salary';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: AppThemeDark.primary,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final nextId = _staffList.isEmpty
                    ? 1
                    : _staffList
                              .map((s) => s.id)
                              .reduce((a, b) => a > b ? a : b) +
                          1;

                Navigator.pop(
                  ctx,
                  _StaffMember(
                    id: nextId,
                    name: nameController.text.trim(),
                    role: selectedRole,
                    phone: phoneController.text.trim(),
                    shift: shiftController.text.trim(),
                    salary: double.parse(
                      salaryController.text.trim().replaceAll(',', '.'),
                    ),
                    isCheckedInToday: false,
                    attendanceLog: const [],
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppThemeDark.primary,
                foregroundColor: AppThemeDark.textPrimary,
              ),
              child: const Text(
                'Add staff',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    phoneController.dispose();
    shiftController.dispose();
    salaryController.dispose();

    if (!mounted || created == null) return;
    setState(() => _staffList.insert(0, created));
  }

  Future<void> _showAddReceptionistDialog() async {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final usernameController = TextEditingController();
    final shiftController = TextEditingController(
      text: 'Morning (08:00 - 16:00)',
    );

    final created = await showDialog<_ReceptionistAccount>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeDark.secondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppThemeDark.borderPrimary),
        ),
        title: CustomText(
          text: 'Add Receptionist Account',
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: fullNameController,
                    autofocus: true,
                    hintText: 'Full name',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter full name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: usernameController,
                    hintText: 'Username (e.g. sara.desk)',
                    validator: (v) {
                      final trimmed = v?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Enter a username';
                      final exists = _receptionistAccounts.any(
                        (a) =>
                            a.username.toLowerCase() == trimmed.toLowerCase(),
                      );
                      if (exists) return 'Username already exists';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: shiftController,
                    hintText: 'Shift',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter shift' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppThemeDark.primary),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final nextId = _receptionistAccounts.isEmpty
                  ? 1
                  : _receptionistAccounts
                            .map((a) => a.userId)
                            .reduce((a, b) => a > b ? a : b) +
                        1;

              Navigator.pop(
                ctx,
                _ReceptionistAccount(
                  userId: nextId,
                  username: usernameController.text.trim(),
                  fullName: fullNameController.text.trim(),
                  shift: shiftController.text.trim(),
                  isActive: true,
                  members: const [],
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeDark.primary,
              foregroundColor: AppThemeDark.textPrimary,
            ),
            child: const Text(
              'Create account',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    fullNameController.dispose();
    usernameController.dispose();
    shiftController.dispose();

    if (!mounted || created == null) return;
    setState(() => _receptionistAccounts.insert(0, created));
  }

  void _showStaffDetails(_StaffMember staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StaffDetailsSheet(
        staff: staff,
        onToggleAttendance: () {
          _toggleStaffAttendance(staff.id);
          Navigator.pop(ctx);
        },
        onDelete: () {
          _deleteStaff(staff.id);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showReceptionistDetails(_ReceptionistAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReceptionistDetailsSheet(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _staffList.where((s) => s.isCheckedInToday).length;
    final totalRegisteredByReceptionists = _receptionistAccounts.fold<int>(
      0,
      (sum, acc) => sum + acc.members.length,
    );

    final filteredStaff = _staffList.where((staff) {
      final matchesRole = _selectedRole == null || staff.role == _selectedRole;
      if (!matchesRole) return false;
      if (_searchQuery.isEmpty) return true;
      return staff.name.toLowerCase().contains(_searchQuery) ||
          staff.role.label.toLowerCase().contains(_searchQuery) ||
          staff.phone.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredReceptionists = _receptionistAccounts.where((acc) {
      if (_searchQuery.isEmpty) return true;
      return acc.fullName.toLowerCase().contains(_searchQuery) ||
          acc.username.toLowerCase().contains(_searchQuery) ||
          acc.members.any((m) => m.name.toLowerCase().contains(_searchQuery));
    }).toList();

    return Container(
      color: AppThemeDark.primaryBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 680;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(GeneralSizes.largeSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff & Receptionists',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppThemeDark.textWhite,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Track staff shifts, daily attendance, and receptionist accounts with their registered members.',
                            style: TextStyle(color: AppThemeDark.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _activeTab == _StaffTab.staff
                          ? _showAddStaffDialog
                          : _showAddReceptionistDialog,
                      icon: const Icon(
                        Icons.person_add_alt_1,
                        size: 18,
                        color: Colors.black,
                      ),
                      label: Text(
                        _activeTab == _StaffTab.staff
                            ? 'Add staff'
                            : 'Add account',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppThemeDark.primary,
                        foregroundColor: AppThemeDark.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Summary Cards
                _StaffSummaryRow(
                  totalStaff: _staffList.length,
                  presentToday: presentCount,
                  receptionistCount: _receptionistAccounts.length,
                  totalMembersRegistered: totalRegisteredByReceptionists,
                ),
                const SizedBox(height: 28),

                // View Switcher + Search / Role Filter
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedButton<_StaffTab>(
                      segments: const [
                        ButtonSegment(
                          value: _StaffTab.staff,
                          label: Text('Staff & Attendance'),
                          icon: Icon(Icons.badge_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: _StaffTab.receptionists,
                          label: Text('Receptionist Accounts'),
                          icon: Icon(Icons.support_agent_outlined, size: 18),
                        ),
                      ],
                      selected: {_activeTab},
                      style: ButtonStyle(
                        foregroundColor: const WidgetStatePropertyAll(
                          AppThemeDark.textWhite,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppThemeDark.primary.withValues(alpha: 0.22)
                              : AppThemeDark.secondary,
                        ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppThemeDark.borderPrimary),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        setState(() {
                          _activeTab = selection.first;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ),
                    SizedBox(
                      width: isCompact ? double.infinity : 300,
                      child: CustomTextField(
                        controller: _searchController,
                        onFieldSubmitted: (_) => _onSearchChanged(),
                        hintText: _activeTab == _StaffTab.staff
                            ? 'Search staff by name or role...'
                            : 'Search account or member name...',
                        icon: HugeIcons.strokeRoundedSearch02,
                        prefixCallBack: () => _searchController.clear(),
                      ),
                    ),
                    if (_activeTab == _StaffTab.staff)
                      SizedBox(
                        width: isCompact ? double.infinity : 190,
                        child: _RoleFilterDropdown(
                          selected: _selectedRole,
                          onChanged: (role) =>
                              setState(() => _selectedRole = role),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Content
                if (_activeTab == _StaffTab.staff)
                  _StaffCardGrid(
                    staffList: filteredStaff,
                    onTap: _showStaffDetails,
                    onQuickToggleAttendance: _toggleStaffAttendance,
                  )
                else
                  _ReceptionistAccountsGrid(
                    accounts: filteredReceptionists,
                    onTap: _showReceptionistDetails,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StaffSummaryRow extends StatelessWidget {
  final int totalStaff;
  final int presentToday;
  final int receptionistCount;
  final int totalMembersRegistered;

  const _StaffSummaryRow({
    required this.totalStaff,
    required this.presentToday,
    required this.receptionistCount,
    required this.totalMembersRegistered,
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
              label: 'Total Staff',
              value: '$totalStaff',
              detail: 'Active gym employees',
              icon: Icons.badge_outlined,
              color: AppThemeDark.primary,
            ),
            _SummaryCard(
              width: width,
              label: 'Checked In Today',
              value: '$presentToday / $totalStaff',
              detail: '${totalStaff - presentToday} not checked in',
              icon: Icons.how_to_reg_outlined,
              color: AppThemeDark.success,
            ),
            _SummaryCard(
              width: width,
              label: 'Receptionist Accounts',
              value: '$receptionistCount',
              detail: '$totalMembersRegistered members registered',
              icon: Icons.support_agent_outlined,
              color: AppThemeDark.info,
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
                      fontSize: 13,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleFilterDropdown extends StatelessWidget {
  final _StaffRole? selected;
  final ValueChanged<_StaffRole?> onChanged;

  const _RoleFilterDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(
          color: selected == null
              ? AppThemeDark.borderPrimary
              : AppThemeDark.primary.withValues(alpha: 0.7),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_StaffRole?>(
          value: selected,
          isExpanded: true,
          dropdownColor: AppThemeDark.secondary,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppThemeDark.textSecondary,
          ),
          style: const TextStyle(
            color: AppThemeDark.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: [
            const DropdownMenuItem<_StaffRole?>(
              value: null,
              child: Text('All roles'),
            ),
            for (final role in _StaffRole.values)
              DropdownMenuItem<_StaffRole?>(
                value: role,
                child: Text(role.label),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StaffCardGrid extends StatelessWidget {
  final List<_StaffMember> staffList;
  final ValueChanged<_StaffMember> onTap;
  final ValueChanged<int> onQuickToggleAttendance;

  const _StaffCardGrid({
    required this.staffList,
    required this.onTap,
    required this.onQuickToggleAttendance,
  });

  @override
  Widget build(BuildContext context) {
    if (staffList.isEmpty) {
      return const _EmptyBox(message: 'No staff members match your search.');
    }

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
            mainAxisExtent: 178,
          ),
          itemCount: staffList.length,
          itemBuilder: (context, index) {
            final staff = staffList[index];
            final lastRecord = staff.attendanceLog.isNotEmpty
                ? staff.attendanceLog.first
                : null;

            return InkWell(
              onTap: () => onTap(staff),
              borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeDark.secondary,
                  borderRadius: BorderRadius.circular(
                    GeneralSizes.borderRadiusM,
                  ),
                  border: Border.all(
                    color: staff.isCheckedInToday
                        ? AppThemeDark.success.withValues(alpha: 0.4)
                        : AppThemeDark.borderPrimary,
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
                            staff.name.isNotEmpty
                                ? staff.name[0].toUpperCase()
                                : 'S',
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
                                staff.name,
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
                                staff.role.label,
                                style: const TextStyle(
                                  color: AppThemeDark.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(
                          label: staff.isCheckedInToday ? 'On Shift' : 'Off',
                          color: staff.isCheckedInToday
                              ? AppThemeDark.success
                              : AppThemeDark.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppThemeDark.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            staff.shift,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppThemeDark.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Divider(
                      color: AppThemeDark.borderPrimary.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lastRecord == null
                              ? 'No logs yet'
                              : 'Last in: ${lastRecord.checkIn}',
                          style: const TextStyle(
                            color: AppThemeDark.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onQuickToggleAttendance(staff.id),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: staff.isCheckedInToday
                                ? AppThemeDark.warning
                                : AppThemeDark.primary,
                          ),
                          child: Text(
                            staff.isCheckedInToday ? 'Check out' : 'Check in',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
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

class _ReceptionistAccountsGrid extends StatelessWidget {
  final List<_ReceptionistAccount> accounts;
  final ValueChanged<_ReceptionistAccount> onTap;

  const _ReceptionistAccountsGrid({
    required this.accounts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const _EmptyBox(
        message: 'No receptionist accounts match your search.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 720
            ? 1
            : constraints.maxWidth < 1150
            ? 2
            : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 196,
          ),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final activeMembersCount = account.members
                .where((m) => m.status.toLowerCase() == 'active')
                .length;

            return InkWell(
              onTap: () => onTap(account),
              borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppThemeDark.secondary,
                  borderRadius: BorderRadius.circular(
                    GeneralSizes.borderRadiusM,
                  ),
                  border: Border.all(color: AppThemeDark.borderPrimary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppThemeDark.info.withValues(
                            alpha: 0.14,
                          ),
                          child: Icon(
                            Icons.support_agent_outlined,
                            color: AppThemeDark.info,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.fullName,
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
                                '@${account.username}',
                                style: TextStyle(
                                  color: AppThemeDark.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(
                          label: account.isActive ? 'Active' : 'Disabled',
                          color: account.isActive
                              ? AppThemeDark.success
                              : AppThemeDark.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      account.shift,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 12,
                      ),
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
                              Icons.groups_outlined,
                              size: 16,
                              color: AppThemeDark.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${account.members.length} ${account.members.length == 1 ? 'member' : 'members'} ($activeMembersCount active)',
                              style: const TextStyle(
                                color: AppThemeDark.textWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppThemeDark.textSecondary,
                          size: 20,
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

class _StaffDetailsSheet extends StatelessWidget {
  final _StaffMember staff;
  final VoidCallback onToggleAttendance;
  final VoidCallback onDelete;

  const _StaffDetailsSheet({
    required this.staff,
    required this.onToggleAttendance,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppThemeDark.primary.withValues(
                        alpha: 0.16,
                      ),
                      child: Text(
                        staff.name.isNotEmpty
                            ? staff.name[0].toUpperCase()
                            : 'S',
                        style: TextStyle(
                          color: AppThemeDark.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            style: const TextStyle(
                              color: AppThemeDark.textWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${staff.role.label} • Staff #${staff.id}',
                            style: const TextStyle(
                              color: AppThemeDark.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(
                      label: staff.isCheckedInToday ? 'On Shift' : 'Off Shift',
                      color: staff.isCheckedInToday
                          ? AppThemeDark.success
                          : AppThemeDark.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppThemeDark.borderPrimary),
                const SizedBox(height: 14),
                _InfoRow(label: 'Phone', value: staff.phone),
                _InfoRow(label: 'Shift', value: staff.shift),
                _InfoRow(
                  label: 'Monthly Salary',
                  value: '\$${staff.salary.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance History',
                      style: TextStyle(
                        color: AppThemeDark.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${staff.attendanceLog.length} logs',
                      style: const TextStyle(
                        color: AppThemeDark.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (staff.attendanceLog.isEmpty)
                  const _EmptyBox(message: 'No attendance records logged yet.')
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppThemeDark.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppThemeDark.borderPrimary),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: staff.attendanceLog.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppThemeDark.borderPrimary.withValues(
                          alpha: 0.5,
                        ),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final record = staff.attendanceLog[index];
                        final statusColor = record.status == 'Present'
                            ? AppThemeDark.success
                            : record.status == 'Late'
                            ? AppThemeDark.warning
                            : AppThemeDark.error;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(record.date),
                                      style: const TextStyle(
                                        color: AppThemeDark.textWhite,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'In: ${record.checkIn}  •  Out: ${record.checkOut ?? 'Active'}',
                                      style: const TextStyle(
                                        color: AppThemeDark.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _StatusPill(
                                label: record.status,
                                color: statusColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: onToggleAttendance,
                      icon: Icon(
                        staff.isCheckedInToday ? Icons.logout : Icons.login,
                        size: 18,
                        color: Colors.black,
                      ),
                      label: Text(
                        staff.isCheckedInToday
                            ? 'Check Out Now'
                            : 'Check In Now',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: staff.isCheckedInToday
                            ? AppThemeDark.warning
                            : AppThemeDark.primary,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remove Staff'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeDark.error,
                        side: BorderSide(
                          color: AppThemeDark.error.withValues(alpha: 0.6),
                        ),
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

class _ReceptionistDetailsSheet extends StatelessWidget {
  final _ReceptionistAccount account;

  const _ReceptionistDetailsSheet({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppThemeDark.info.withValues(
                        alpha: 0.16,
                      ),
                      child: Icon(
                        Icons.support_agent_outlined,
                        color: AppThemeDark.info,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.fullName,
                            style: const TextStyle(
                              color: AppThemeDark.textWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${account.username} • Account #${account.userId}',
                            style: const TextStyle(
                              color: AppThemeDark.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(
                      label: account.isActive ? 'Active' : 'Disabled',
                      color: account.isActive
                          ? AppThemeDark.success
                          : AppThemeDark.error,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppThemeDark.borderPrimary),
                const SizedBox(height: 14),
                _InfoRow(label: 'Shift', value: account.shift),
                _InfoRow(
                  label: 'Registered Members',
                  value: '${account.members.length}',
                ),
                const SizedBox(height: 22),
                const Text(
                  'Members Registered by This Account',
                  style: TextStyle(
                    color: AppThemeDark.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (account.members.isEmpty)
                  const _EmptyBox(
                    message: 'No members registered under this account yet.',
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppThemeDark.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppThemeDark.borderPrimary),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: account.members.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppThemeDark.borderPrimary.withValues(
                          alpha: 0.5,
                        ),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final member = account.members[index];
                        final statusLower = member.status.toLowerCase();
                        final statusColor = statusLower == 'active'
                            ? AppThemeDark.success
                            : statusLower == 'cancelled'
                            ? AppThemeDark.warning
                            : AppThemeDark.error;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppThemeDark.primary
                                    .withValues(alpha: 0.14),
                                child: Text(
                                  member.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppThemeDark.primary,
                                    fontWeight: FontWeight.bold,
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
                                      style: const TextStyle(
                                        color: AppThemeDark.textWhite,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${member.plan} • Joined ${member.joinedDate}',
                                      style: const TextStyle(
                                        color: AppThemeDark.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _StatusPill(
                                label: member.status,
                                color: statusColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

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

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;

  const _EmptyBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
