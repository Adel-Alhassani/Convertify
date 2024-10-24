import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AppImages {
  static final SvgPicture enabledBottomArrowIcon =
      SvgPicture.asset("assets/icon/enabled/enabled_bottom_arrow.svg");
  static final SvgPicture disabledBottomArrowIcon =
      SvgPicture.asset("assets/icon/disabled/disabled_bottom_arrow.svg");
  static final SvgPicture disabledHeadArrowIcon =
      SvgPicture.asset("assets/icon/disabled/disabled_head_arrow.svg");
  static final SvgPicture enabledHeadArrowIcon =
      SvgPicture.asset("assets/icon/enabled/enabled_head_arrow.svg");
  static final SvgPicture fileSuccessIcon =
      SvgPicture.asset("assets/icon/file_success.svg");
  static final SvgPicture emptyFile =
      SvgPicture.asset("assets/icon/empty_file.svg");
  static final SvgPicture converting =
      SvgPicture.asset("assets/icon/converting.svg");
  static final SvgPicture addFile = SvgPicture.asset(
    "assets/icon/add_file.svg",
    height: 65.h,
    width: 65.w,
  );
  static final SvgPicture downloadIcon =
      SvgPicture.asset("assets/icon/download.svg");
}
