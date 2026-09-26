import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'tokens.dart';

/// Canlı yayın denetimleri: sarma anlamsız, ilerleme çubuğu ve süre yok.
const liveControls = MaterialDesktopVideoControlsThemeData(
  displaySeekBar: false,
  buttonBarButtonSize: 24,
  volumeBarActiveColor: AppColors.accentColor,
  volumeBarThumbColor: AppColors.accentColor,
  bottomButtonBar: [
    MaterialDesktopPlayOrPauseButton(),
    MaterialDesktopVolumeButton(),
    Spacer(),
    MaterialDesktopFullscreenButton(),
  ],
);

/// Film ve bölüm denetimleri: vurgu renginde ilerleme çubuğu.
const vodControls = MaterialDesktopVideoControlsThemeData(
  buttonBarButtonSize: 24,
  seekBarPositionColor: AppColors.accentColor,
  seekBarThumbColor: AppColors.accentColor,
  seekBarColor: Color(0x33FFFFFF),
  seekBarBufferColor: Color(0x55FFFFFF),
  volumeBarActiveColor: AppColors.accentColor,
  volumeBarThumbColor: AppColors.accentColor,
);
