import 'dart:developer';

import 'package:flutter/material.dart' hide ConnectionState;

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/audio_model.dart';
import 'package:fladder/models/items/chapters_model.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/models/items/media_segments_model.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/items/trick_play_model.dart';
import 'package:fladder/models/playback/direct_playback_model.dart';
import 'package:fladder/models/playback/offline_playback_model.dart';
import 'package:fladder/models/playback/playback_queue_state.dart';
import 'package:fladder/models/playback/transcode_playback_model.dart';
import 'package:fladder/models/playback/tv_playback_model.dart';
import 'package:fladder/models/playback/playback_queue_source.dart';
import 'package:fladder/models/video_stream_model.dart';
import 'package:fladder/models/settings/video_player_settings.dart';
import 'package:fladder/providers/api_provider.dart';
import 'package:fladder/util/bitrate_helper.dart';
import 'package:fladder/util/localization_helper.dart';
export 'playback_queue_source.dart';
import 'package:fladder/wrappers/media_control_wrapper.dart';


class Media {
  final String url;

  const Media({
    required this.url,
  });
}

extension PlaybackModelExtension on PlaybackModel? {
  SubStreamModel? get defaultSubStream {
    final streams = this?.subStreams;
    if (streams == null) return null;
    return streams.firstWhereOrNull((element) => element.index == this?.mediaStreams?.defaultSubStreamIndex) ??
        SubStreamModel.no();
  }

  AudioStreamModel? get defaultAudioStream {
    final streams = this?.audioStreams;
    if (streams == null) return null;
    return streams.firstWhereOrNull((element) => element.index == this?.mediaStreams?.defaultAudioStreamIndex) ??
        AudioStreamModel.no();
  }

  String? label(BuildContext context) => switch (this) {
        DirectPlaybackModel _ => PlaybackType.directStream.name(context),
        TranscodePlaybackModel _ => PlaybackType.transcode.name(context),
        OfflinePlaybackModel _ => PlaybackType.offline.name(context),
        TvPlaybackModel _ => PlaybackType.tv.name(context),
        _ => context.localized.unknown,
      };
}

class PlaybackModel {
  final ItemBaseModel item;
  final Media? media;
  final PlaybackQueueState playbackQueue;
  List<ItemBaseModel> get queue => playbackQueue.queue;
  List<ItemBaseModel> get nextUpQueue => playbackQueue.nextUpQueue;
  final PlaybackQueueSource? queueSource;
  final MediaSegmentsModel? mediaSegments;
  final PlaybackInfoResponse? playbackInfo;

  Map<Bitrate, bool> bitRateOptions;

  List<Chapter>? chapters = [];
  TrickPlayModel? trickPlay;

  Future<PlaybackModel?> updatePlaybackPosition(Duration position, bool isPlaying, Ref ref) =>
      throw UnimplementedError();
  Future<PlaybackModel?> playbackStarted(Duration position, Ref ref) => throw UnimplementedError();
  Future<PlaybackModel?> playbackStopped(Duration position, Duration? totalDuration, Ref ref) =>
      throw UnimplementedError();

  void dispose() {}

  final MediaStreamsModel? mediaStreams;
  List<SubStreamModel>? get subStreams => throw UnimplementedError();
  List<AudioStreamModel>? get audioStreams => throw UnimplementedError();

  bool get isAudioPlayback => item is AudioModel || item.type == FladderItemType.audio;

  Duration resolvedStopPosition(Duration position, Duration? totalDuration) {
    if (!isAudioPlayback) return position;
    return totalDuration ?? item.overview.runTime ?? position;
  }

  Future<Duration> resolvedStartPosition([Duration? requestedStartPosition]) async {
    if (isAudioPlayback) return Duration.zero;
    return requestedStartPosition ?? await startDuration() ?? Duration.zero;
  }

  Future<Duration>? startDuration() async => isAudioPlayback ? Duration.zero : item.userData.playBackPosition;

  PlaybackModel? updateUserData(UserData userData) => throw UnimplementedError();

  Future<PlaybackModel>? setSubtitle(SubStreamModel? model, MediaControlsWrapper player) => throw UnimplementedError();
  Future<PlaybackModel>? setAudio(AudioStreamModel? model, MediaControlsWrapper player) => throw UnimplementedError();
  Future<PlaybackModel>? setQualityOption(Map<Bitrate, bool> map) => throw UnimplementedError();

  PlaybackModel updatePlaybackQueue(PlaybackQueueState newQueue) => throw UnimplementedError();

  ItemBaseModel? get nextVideo => playbackQueue.nextItem(item.id);
  ItemBaseModel? get previousVideo => playbackQueue.previousItem(item.id);

  PlaybackModel copyWith({
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
  }) =>
      throw UnimplementedError();

  PlaybackModel({
    required this.playbackInfo,
    this.mediaStreams,
    required this.item,
    required this.media,
    List<ItemBaseModel> queue = const [],
    PlaybackQueueState? playbackQueue,
    this.queueSource,
    this.bitRateOptions = const {},
    this.mediaSegments,
    this.chapters,
    this.trickPlay,
  }) : playbackQueue = playbackQueue ??
            PlaybackQueueState.fromQueue(
              queue,
              initialItemId: item.id,
            );
}

