import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/providers/video_player_provider.dart';
import 'package:fladder/widgets/full_screen_helpers/full_screen_wrapper.dart';

class FullScreenHelper implements FullScreenWrapper {
  const FullScreenHelper._();
  factory FullScreenHelper.instantiate() => const FullScreenHelper._();

  @override
  Future<void> closeFullScreen(WidgetRef ref) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(fullScreen: false));
  }

  @override
  Future<void> toggleFullScreen(WidgetRef ref) async {
    final isFullScreen = ref.read(mediaPlaybackProvider).fullScreen;
    if (isFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(fullScreen: !isFullScreen));
  }
}
