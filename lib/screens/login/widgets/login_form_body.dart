import 'package:flutter/material.dart';
import 'package:gym_zero/shared/constants/general_sizes.dart';
import 'package:gym_zero/shared/theme/app_theme.dart';

import '../../../shared/widgets/custom_text.dart';

class LoginFormBody extends StatelessWidget {
  const LoginFormBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GeneralSizes.borderRadiusM),
        color: AppThemeDark.secondary,
        border: Border.all(color: AppThemeDark.borderPrimary, width: 2),
      ),
      child: Column(
        children: [
          verticalSpaceMedium(),
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 50,
            child: Icon(Icons.lock, color: AppThemeDark.secondary, size: 35),
          ),
          verticalSpaceSmall(),
          CustomText(
            text: 'Login',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          verticalSpaceSmall(),
          CustomText(
            text: 'enter your info',
            color: Colors.white,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
