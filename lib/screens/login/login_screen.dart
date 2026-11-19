import 'package:flutter/material.dart';

import '../../shared/constants/general_sizes.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/login_form_body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeDark.primaryBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 860;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: GeneralSizes.largeSize,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 64).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: isCompact
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CompactBrandHeader(),
                              SizedBox(height: 28),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 440),
                                child: LoginFormBody(),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 5, child: _WideBrandPanel()),
                              SizedBox(width: 56),
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 430),
                                    child: LoginFormBody(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WideBrandPanel extends StatelessWidget {
  const _WideBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppThemeDark.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppThemeDark.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: AppThemeDark.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Gym Zero',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppThemeDark.textWhite,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Manage members, active subscriptions, payments, and gym expenses from one local workspace.',
          style: TextStyle(
            color: AppThemeDark.textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        const _FeatureHighlight(
          icon: Icons.groups_outlined,
          title: 'Member & Subscription Control',
          subtitle: 'Track active plans, renewals, and expired memberships.',
        ),
        const SizedBox(height: 14),
        const _FeatureHighlight(
          icon: Icons.payments_outlined,
          title: 'Revenue & Expense Tracking',
          subtitle: 'Keep member payments and operating costs synchronized.',
        ),
        const SizedBox(height: 14),
        const _FeatureHighlight(
          icon: Icons.assessment_outlined,
          title: 'Instant Financial Reports',
          subtitle: 'Generate and archive period reports in seconds.',
        ),
      ],
    );
  }
}

class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppThemeDark.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppThemeDark.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: AppThemeDark.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Gym Zero',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppThemeDark.textWhite,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gym Management Workspace',
          style: TextStyle(color: AppThemeDark.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureHighlight({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppThemeDark.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: AppThemeDark.primary, size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppThemeDark.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
