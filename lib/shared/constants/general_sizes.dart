import 'package:flutter/widgets.dart';

class GeneralSizes {
  static const double smallSize = 4.0;
  static const double mediumSize = 8.0;
  static const double largeSize = 16.0;

  static const double borderRadiusS = 12.0;
  static const double borderRadiusM = 16.0;
  static const double borderRadiusL = 20.0;
}

Widget verticalSpaceSmall() {
  return SizedBox(height: GeneralSizes.smallSize);
}

Widget verticalSpaceMedium() {
  return SizedBox(height: GeneralSizes.mediumSize);
}

Widget verticalSpaceLarge() {
  return SizedBox(height: GeneralSizes.largeSize);
}

Widget horizontalSpaceSmall() {
  return SizedBox(width: GeneralSizes.smallSize);
}

Widget horizontalSpaceMedium() {
  return SizedBox(width: GeneralSizes.mediumSize);
}

Widget horizontalSpaceLarge() {
  return SizedBox(width: GeneralSizes.largeSize);
}
