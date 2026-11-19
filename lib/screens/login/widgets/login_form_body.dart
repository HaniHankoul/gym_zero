import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_zero/shared/constants/general_sizes.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';

import '../../../providers/navigation_provider.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/universal_button.dart';

class LoginFormBody extends ConsumerStatefulWidget {
  const LoginFormBody({super.key});

  @override
  ConsumerState<LoginFormBody> createState() => _LoginFormBodyState();
}

class _LoginFormBodyState extends ConsumerState<LoginFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(navigationProvider.notifier).select(NavigationSection.home);
    context.go('/');
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppThemeDark.textSecondary,
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: AppThemeDark.textSecondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppThemeDark.primaryBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemeDark.borderPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeDark.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemeDark.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppThemeDark.error, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppThemeDark.secondary,
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        border: Border.all(color: AppThemeDark.borderPrimary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppThemeDark.primary.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: AppThemeDark.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Welcome back',
                        color: AppThemeDark.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sign in to access your dashboard',
                        style: TextStyle(
                          color: AppThemeDark.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(
              color: AppThemeDark.borderPrimary.withValues(alpha: 0.6),
              height: 1,
            ),
            const SizedBox(height: 24),
            const Text(
              'Username',
              style: TextStyle(
                color: AppThemeDark.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppThemeDark.textWhite),
              decoration: _inputDecoration(
                hintText: 'Enter your username',
                prefixIcon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Password',
              style: TextStyle(
                color: AppThemeDark.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignIn(),
              style: const TextStyle(color: AppThemeDark.textWhite),
              decoration: _inputDecoration(
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppThemeDark.textSecondary,
                    size: 20,
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            UniversalButton(
              onTap: _handleSignIn,
              title: 'Sign in',
              icon: Icons.arrow_forward_rounded,
              color: AppThemeDark.primary,
              textColor: AppThemeDark.textPrimary,
              borderColor: AppThemeDark.primary,
            ),
          ],
        ),
      ),
    );
  }
}
