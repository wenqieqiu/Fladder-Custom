import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/models/playback/playback_queue_state.dart';
import 'package:fladder/providers/api_provider.dart';
import 'package:fladder/util/bitrate_helper.dart';
import 'package:fladder/util/duration_extensions.dart';
import 'package:fladder/wrappers/media_control_wrapper.dart';

/// Mixin that implements the common server-based playback logic shared by
/// [DirectPlaybackModel] and [TranscodePlaybackModel].
///
mixin ServerPlaybackModelMixin on PlaybackModel {
  /// The playback method reported to the server (directplay or transcode).
  PlayMethod get playMethod;

  /// An optional session identifier (used by transcode playback).
  String? get sessionId;

  // ---------------------------------------------------------------------------
  // Shared getters
  // ---------------------------------------------------------------------------

  @override
  List<SubStreamModel> get subStreams =>
      [SubStreamModel.no(), ...mediaStreams?.subStreams ?? []];

  /// The items in the current playback queue.
  List<QueueItem> get itemsInQueue =>
      queue.mapIndexed((index, element) => QueueItem(id: element.id, playlistItemId: "playlistItem$index")).toList();

  @override
  List<AudioStreamModel> get audioStreams =>
      [AudioStreamModel.no(), ...mediaStreams?.audioStreams ?? []];

  // ---------------------------------------------------------------------------
  // Shared methods
  // ---------------------------------------------------------------------------

  @override
  Future<PlaybackModel> setSubtitle(SubStreamModel? model, MediaControlsWrapper player) async {
    final newIndex = await player.setSubtitleTrack(model, this);
    return copyWith(
      mediaStreams: () => mediaStreams?.copyWith(defaultSubStreamIndex: newIndex),
    );
  }

  @override
  Future<PlaybackModel>? setAudio(AudioStreamModel? model, MediaControlsWrapper player) async {
    final newIndex = await player.setAudioTrack(model, this);
    return copyWith(
      mediaStreams: () => mediaStreams?.copyWith(defaultAudioStreamIndex: newIndex),
    );
  }


  @override
  Future<PlaybackModel?> playbackStopped(Duration position, Duration? totalDuration, Ref ref) async {
    final stopPosition = resolvedStopPosition(position, totalDuration);

    await ref.read(jellyApiProvider).sessionsPlayingStoppedPost(
          body: PlaybackStopInfo(
            itemId: item.id,
            mediaSourceId: item.id,
            playSessionId: playbackInfo?.playSessionId,
            positionTicks: stopPosition.toRuntimeTicks,
          ),
        );

    return null;
  }
  @override
  String toString() => '${runtimeType}(item: $item, playbackInfo: $playbackInfo)';
}
