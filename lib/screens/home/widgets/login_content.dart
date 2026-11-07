import 'package:flutter/material.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';
import 'package:gym_zero/shared/widgets/custom_text.dart';
import 'package:gym_zero/shared/widgets/universal_button.dart';

import '../../../shared/constants/general_sizes.dart';

class LoginContent extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeneralSizes.largeSize),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: AppThemeDark.secondary,
          borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeneralSizes.mediumSize,
            vertical: GeneralSizes.smallSize,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GeneralSizes.mediumSize,
                  vertical: GeneralSizes.largeSize,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppThemeDark.primary,
                      child: Icon(Icons.person, color: Colors.black, size: 24),
                    ),
                    horizontalSpaceSmall(),
                    CustomText(
                      text: 'Username',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              verticalSpaceSmall(),
              verticalSpaceSmall(),
              UniversalButton(
                onTap: () {},
                title: 'Log Out',
                color: AppThemeDark.primary,
                textColor: Colors.black,
                borderColor: AppThemeDark.primary,
                icon: Icons.logout,
              ),
              verticalSpaceSmall(),
            ],
          ),
        ),
      ),
    );
  }
}
