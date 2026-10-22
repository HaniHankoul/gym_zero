import 'package:flutter/material.dart';
import 'package:gym_zero/shared/constants/general_sizes.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';
import 'package:gym_zero/shared/widgets/custom_text_field.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/universal_button.dart';

class LoginFormBody extends StatelessWidget {
  const LoginFormBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        color: AppThemeDark.secondary,
        border: Border.all(color: AppThemeDark.borderPrimary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: GeneralSizes.smallSize,
          horizontal: GeneralSizes.largeSize,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            verticalSpaceMedium(),
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.orange.withAlpha(150),
                child: CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 45,
                  child: Icon(
                    Icons.lock,
                    color: AppThemeDark.secondary,
                    size: 35,
                  ),
                ),
              ),
            ),
            verticalSpaceSmall(),
            Center(
              child: CustomText(
                text: 'Login',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpaceSmall(),
            Center(
              child: CustomText(
                text: 'enter your info',
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            verticalSpaceMedium(),
            CustomText(text: 'username', color: Colors.white, fontSize: 16),
            verticalSpaceSmall(),
            CustomTextField(
              hintText: 'username',
              icon: HugeIcons.strokeRoundedPersonStanding,
            ),

            verticalSpaceSmall(),
            CustomText(text: 'password', color: Colors.white, fontSize: 16),
            verticalSpaceSmall(),
            CustomTextField(
              hintText: 'password',
              icon: HugeIcons.strokeRoundedLockPassword,
            ),
            verticalSpaceLarge(),
            verticalSpaceLarge(),
            UniversalButton(
              onTap: () {},
              title: 'Sign in',
              icon: Icons.arrow_forward,
              color: AppThemeDark.primary,
              textColor: AppThemeDark.textPrimary,
              borderColor: AppThemeDark.primary,
            ),
            verticalSpaceLarge(),
            verticalSpaceLarge(),
          ],
        ),
      ),
    );
  }
}
