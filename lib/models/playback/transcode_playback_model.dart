import 'package:flutter/widgets.dart' hide RepeatMode;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/chapters_model.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/models/items/media_segments_model.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/items/trick_play_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/models/playback/playback_queue_state.dart';
import 'package:fladder/models/playback/playback_queue_source.dart';
import 'package:fladder/models/playback/server_playback_mixin.dart';
import 'package:fladder/providers/api_provider.dart';
import 'package:fladder/util/bitrate_helper.dart';
import 'package:fladder/util/duration_extensions.dart';

class TranscodePlaybackModel extends PlaybackModel with ServerPlaybackModelMixin {
  TranscodePlaybackModel({
    required super.item,
    required super.media,
    required super.playbackInfo,
    super.mediaStreams,
    super.mediaSegments,
    super.chapters,
    super.trickPlay,
    super.queue = const [],
    super.playbackQueue,
    super.queueSource,
    super.bitRateOptions,
  });

  @override
  PlayMethod get playMethod => PlayMethod.transcode;

  @override
  String? get sessionId => playbackInfo?.playSessionId;


  @override
  Future<PlaybackModel?> playbackStarted(Duration position, Ref ref) async {
    await ref.read(jellyApiProvider).sessionsPlayingPost(
          body: PlaybackStartInfo(
            canSeek: true,
            itemId: item.id,
            mediaSourceId: item.id,
            playSessionId: playbackInfo?.playSessionId,
            sessionId: playbackInfo?.playSessionId,
            subtitleStreamIndex: item.streamModel?.defaultSubStreamIndex,
            audioStreamIndex: item.streamModel?.defaultAudioStreamIndex,
            volumeLevel: 100,
            playbackStartTimeTicks: position.toRuntimeTicks,
            playMethod: PlayMethod.transcode,
            isMuted: false,
            isPaused: false,
            repeatMode: RepeatMode.repeatall,
          ),
        );
    return null;
  }

  @override
  Future<PlaybackModel?> updatePlaybackPosition(Duration position, bool isPlaying, Ref ref) async {
    final api = ref.read(jellyApiProvider);
    await api.sessionsPlayingProgressPost(
      body: PlaybackProgressInfo(
        canSeek: true,
        itemId: item.id,
        mediaSourceId: item.id,
        playSessionId: playbackInfo?.playSessionId,
        sessionId: playbackInfo?.playSessionId,
        subtitleStreamIndex: item.streamModel?.defaultSubStreamIndex,
        audioStreamIndex: item.streamModel?.defaultAudioStreamIndex,
        volumeLevel: 100,
        positionTicks: position.toRuntimeTicks,
        playMethod: PlayMethod.transcode,
        isPaused: !isPlaying,
        isMuted: false,
        repeatMode: RepeatMode.repeatall,
      ),
    );
    return this;
  }

  @override
  Future<PlaybackModel>? setQualityOption(Map<Bitrate, bool> map) async {
    return copyWith(bitRateOptions: map);
  }

  @override
  PlaybackModel? updateUserData(UserData userData) {
    return copyWith(
      item: item.copyWith(userData: userData),
    );
  }

  @override
  PlaybackModel updatePlaybackQueue(PlaybackQueueState newQueue) {
    return copyWith(playbackQueue: newQueue);
  }

  @override
  TranscodePlaybackModel copyWith({
    ItemBaseModel? item,
    ValueGetter<Media?>? media,
    ValueGetter<Duration>? lastPosition,
    PlaybackInfoResponse? playbackInfo,
    ValueGetter<MediaStreamsModel?>? mediaStreams,
    ValueGetter<MediaSegmentsModel?>? mediaSegments,
    ValueGetter<List<Chapter>?>? chapters,
    ValueGetter<TrickPlayModel?>? trickPlay,
    List<ItemBaseModel>? queue,
    PlaybackQueueState? playbackQueue,
    PlaybackQueueSource? queueSource,
    Map<Bitrate, bool>? bitRateOptions,
  }) {
    return TranscodePlaybackModel(
      item: item ?? this.item,
      media: media != null ? media() : this.media,
      playbackInfo: playbackInfo ?? this.playbackInfo,
      mediaStreams: mediaStreams != null ? mediaStreams() : this.mediaStreams,
      mediaSegments: mediaSegments != null ? mediaSegments() : this.mediaSegments,
      chapters: chapters != null ? chapters() : this.chapters,
      trickPlay: trickPlay != null ? trickPlay() : this.trickPlay,
      queue: queue ?? this.queue,
      playbackQueue: playbackQueue ?? this.playbackQueue,
      queueSource: queueSource ?? this.queueSource,
      bitRateOptions: bitRateOptions ?? this.bitRateOptions,
    );
  }
}
