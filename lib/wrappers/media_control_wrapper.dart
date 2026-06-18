import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/audio_model.dart';
import 'package:fladder/models/items/channel_model.dart';
import 'package:fladder/models/items/item_stream_model.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/media_playback_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/models/playback/playback_queue_state.dart';
import 'package:fladder/models/settings/video_player_settings.dart';
import 'package:fladder/providers/api_provider.dart';
import 'package:fladder/providers/live_tv_provider.dart';
import 'package:fladder/providers/settings/client_settings_provider.dart';
import 'package:fladder/providers/settings/subtitle_settings_provider.dart';
import 'package:fladder/providers/settings/video_player_settings_provider.dart';
import 'package:fladder/providers/video_player_provider.dart';
import 'package:fladder/generated/video_player_helper.g.dart' hide PlaybackState;
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/wrappers/players/base_player.dart';
import 'package:fladder/providers/playback_model_helper.dart';
import 'package:fladder/wrappers/players/lib_mpv.dart';
import 'package:fladder/wrappers/players/lib_mdk.dart';
import 'package:fladder/wrappers/players/native_player.dart';
import 'package:fladder/wrappers/players/player_states.dart';
import 'package:fladder/wrappers/audio_queue_manager.dart';

class MediaControlsWrapper extends BaseAudioHandler implements VideoPlayerControlsCallback {
  MediaControlsWrapper({required this.ref});

  BasePlayer? _player;
  final StreamController<PlayerState> _stateController = StreamController.broadcast();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool get hasPlayer => _player != null;

  PlayerOptions? get backend => switch (_player) {
        LibMPV _ => PlayerOptions.libMPV,
        LibMDK _ => PlayerOptions.libMDK,
        _ => null,
      };

  Stream<PlayerState> get stateStream => _stateController.stream;
  PlayerState? get lastState => _player?.lastState;

  Widget? subtitleWidget(bool showOverlay, {GlobalKey? controlsKey}) =>
      _player?.subtitles(showOverlay, controlsKey: controlsKey);
  Widget? videoWidget(Key key, BoxFit fit) => _player?.videoWidget(key, fit);

  final Ref ref;

  List<StreamSubscription> subscriptions = [];
  ProviderSubscription? _subtitleSettingsSubscription;

  bool initializedWrapper = false;
  bool _isNewPlayback = false;
  late final AudioQueueManager _audioQueueManager;
  Future<void> init() async {
    if (!initializedWrapper) {
      initializedWrapper = true;
      _audioQueueManager = AudioQueueManager(ref);
      _audioQueueManager.onSetupPlayer = () async => setup(LibMPV());
      _audioQueueManager.onRefreshMediaControls = (model, playing) async =>
          _refreshMediaControls(model: model, playing: playing);
      _audioQueueManager.onPlay = () async => play();
      if (!kIsWeb && Platform.isAndroid) {
        VideoPlayerControlsCallback.setUp(this);
      }
      await AudioService.init(
        builder: () => this,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'nl.jknaapen.fladder.channel.playback',
          androidNotificationChannelName: 'Video playback',
          androidNotificationIcon: 'drawable/ic_notification',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          rewindInterval: Duration(seconds: 10),
          fastForwardInterval: Duration(seconds: 15),
          androidNotificationChannelDescription: "Playback",
          androidShowNotificationBadge: true,
        ),
      );
    }

    final player = switch (ref.read(videoPlayerSettingsProvider).wantedPlayer) {
      PlayerOptions.libMDK => LibMDK(),
      PlayerOptions.libMPV => LibMPV(),
      PlayerOptions.nativePlayer => NativePlayer(),
    };

    setup(player);
  }

  Future<void> dispose() async {
    _subtitleSettingsSubscription?.close();
    await _playerStateSubscription?.cancel();
    _player?.dispose();
  }

  Future<void> setup(BasePlayer newPlayer) async {
    final oldPlayer = _player;
    if (oldPlayer != null && oldPlayer != newPlayer && _audioQueueManager.previousPlayer != oldPlayer) {
      await oldPlayer.dispose();
    }

    _player = newPlayer;
    _audioQueueManager.attachPlayer(_player);
    await newPlayer.init(ref.read(videoPlayerSettingsProvider));
    _initPlayer();
    _subscribePlayerState();
  }

  void _initPlayer() {
    _subtitleSettingsSubscription?.close();
    for (var element in subscriptions) {
      element.cancel();
    }
    _subscribePlayer();
    _subtitleSettingsSubscription = ref.listen(subtitleSettingsProvider, (_, next) {
      _player?.applySubtitleSettings(next);
    });
  }


  void _subscribePlayerState() {
    _playerStateSubscription?.cancel();
    final player = _player;
    if (player == null) return;

    _playerStateSubscription = player.stateStream.listen((state) {
      if (!_stateController.isClosed) {
        _stateController.add(state);
      }
    });
  }

  Future<void> loadVideo(PlaybackModel model, Duration startPosition, bool play) async {
    if (_player is NativePlayer) {
      final context = ref.read(localizationContextProvider);
      await (_player as NativePlayer).sendPlaybackDataToNative(context, model, startPosition);
    }
    _isNewPlayback = play;
    await _player?.loadVideo(model.media?.url ?? "", play, startPosition: startPosition);
    _player?.applySubtitleSettings(ref.read(subtitleSettingsProvider));

  }

  Future<void> updateTVGuide(TVGuideModel guide) async {
    if (_player is NativePlayer) {
      (_player as NativePlayer).sendTVGuideModel(guide);
    }
  }

  Future<void> _restorePreviousPlayer() async {
    if (_audioQueueManager.previousPlayer == null) return;
    await setup(_audioQueueManager.previousPlayer!);
    _audioQueueManager.previousPlayer = null;
  }
  Future<void> openPlayer(BuildContext context) async => _player?.open(context);

  Future<void> _updatePositionWithRetry(PlaybackModel model, Duration position, bool isPlaying) async {
    try {
      await model.updatePlaybackPosition(position, isPlaying, ref);
    } catch (error, stackTrace) {
      log('Failed to send playing: $isPlaying state to server. Retrying once. Error: $error\n$stackTrace');
      try {
        await Future.delayed(const Duration(milliseconds: 250));
        await model.updatePlaybackPosition(position, isPlaying, ref);
      } catch (retryError, retryStackTrace) {
        log('Retry failed for playing: $isPlaying state update. Error: $retryError\n$retryStackTrace');
      }
    }
  }

  void _subscribePlayer() {
    subscriptions.add(_player!.stateStream.listen((value) {
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: value.buffer,
        processingState: value.buffering ? AudioProcessingState.buffering : AudioProcessingState.ready,
        updatePosition: value.position,
        playing: value.playing,
      ));
      if (value.completed && !_audioQueueManager.audioQueueTransitioning) {
        _audioQueueManager.onTrackCompleted();
      }
    }));
  }
  @override
  Future<void> skipToNext() async {
    if (_audioQueueManager.isAudioQueueMode) {
      await _audioQueueManager.skipNext();
      return;
    }
    return loadNextVideo();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_audioQueueManager.isAudioQueueMode) {
      if (_player?.lastState.position != null && _player!.lastState.position >= const Duration(seconds: 3)) {
        await _player?.seek(Duration.zero);
        return;
      }
      await _audioQueueManager.skipPrevious();
      return;
    }
    return loadPreviousVideo();
  }


  @override
  Future<void> pause() async {
    await _player?.pause();
    final position = _player?.lastState.position ?? Duration.zero;
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      updatePosition: position,
      controls: [MediaControl.play],
    ));
    await WakelockPlus.disable();
    final playerState = _player;
    if (playerState != null) {
      final model = ref.read(playBackModel);
      if (model != null) {
        await _updatePositionWithRetry(model, position, false);
        await _refreshMediaControls(model: model, playing: false);
      }
    }
    return super.pause();
  }

  @override
  Future<void> play() async {
    // Only enable wakelock for video; audio can continue with screen off
    final playBackItem = ref.read(playBackModel.select((value) => value?.item));
    if (playBackItem is! AudioModel) {
      await WakelockPlus.enable();
    }

    await _player?.play();

    final currentPosition = await ref.read(playBackModel.select((value) => value?.startDuration()));
    if (_isNewPlayback || !playbackState.value.playing) {
      _isNewPlayback = false;
      await ref.read(playBackModel)?.playbackStarted(currentPosition ?? Duration.zero, ref);
    }
    if (playBackItem == null) return;

    final playbackModel = ref.read(playBackModel);
    if (playbackModel != null) {
      await _refreshMediaControls(model: playbackModel, playing: true);
    }

    return super.play();
  }

  Future<void> _refreshMediaControls({PlaybackModel? model, required bool playing}) async {
    if (!ref.read(clientSettingsProvider).enableMediaKeys) return;
    final playbackModel = model ?? ref.read(playBackModel);
    if (playbackModel == null) return;

    final playBackItem = playbackModel.item;
    final poster =
        playBackItem.images?.primary ?? (playBackItem is ItemStreamModel ? playBackItem.parentImages?.primary : null);
    final currentPosition = _player?.lastState.position ?? await playbackModel.startDuration() ?? Duration.zero;


    final hasNextVideo = ref.read(playBackModel.select((value) => value?.nextVideo != null));
    final hasPreviousVideo = ref.read(playBackModel.select((value) => value?.previousVideo != null));

    final queue = playbackModel.queue;
    final currentQueueIndex = queue.indexWhere((entry) => entry.id == playbackModel.item.id);
    final hasAudioQueue = queue.length > 1;
    final hasNextAudio = hasAudioQueue && (currentQueueIndex >= 0 ? currentQueueIndex < queue.length - 1 : true);
    final hasPreviousAudio = _audioQueueManager.isAudioQueueMode || (hasAudioQueue && (currentQueueIndex > 0 || currentQueueIndex == -1));

    final canSkipNext = hasNextVideo || hasNextAudio;
    final canSkipPrevious = hasPreviousVideo || hasPreviousAudio;

    final isMusic = playBackItem is AudioModel;

    final album = playBackItem is AudioModel ? playBackItem.album : null;
    final artist = playBackItem is AudioModel ? playBackItem.artistModel?.name : null;

    mediaItem.add(MediaItem(
      id: playBackItem.id,
      album: album,
      artist: artist,
      title: playBackItem.title,
      genre: playBackItem.overview.genres.join(', '),
      rating: Rating.newHeartRating(playBackItem.userData.isFavourite),
      duration: playBackItem.overview.runTime ?? const Duration(seconds: 0),
      artUri: poster != null ? _imageDataToUri(poster.path) : null,
    ));
    playbackState.add(PlaybackState(
      playing: playing,
      updatePosition: currentPosition,
      bufferedPosition: _player?.lastState.buffer ?? playbackState.value.bufferedPosition,
      controls: [
        if (playing) MediaControl.pause else MediaControl.play,
        if (canSkipNext) MediaControl.skipToNext,
        if (canSkipPrevious) MediaControl.skipToPrevious,
      ],
      systemActions: {
        if (canSkipNext) MediaAction.skipToNext,
        if (canSkipPrevious) MediaAction.skipToPrevious,
        MediaAction.seek,
        if (!isMusic) MediaAction.fastForward,
        MediaAction.setSpeed,
        if (!isMusic) MediaAction.rewind,
      },
      processingState:
          (_player?.lastState.buffering ?? false) ? AudioProcessingState.buffering : AudioProcessingState.ready,
    ));
  }


  @override
  Future<void> stop() async {
    final playbackModel = ref.read(playBackModel);
    if (playbackModel == null) return;

    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(state: VideoPlayerState.disposed));
    WakelockPlus.disable();
    _player?.stop();

    final position = _player?.lastState.position;
    final totalDuration = _player?.lastState.duration;

    // Small delay so we don't post right after playback/progress update
    await Future.delayed(const Duration(seconds: 1));

    await playbackModel.playbackStopped(position ?? Duration.zero, totalDuration, ref);
    ref.read(playBackModel.notifier).update((_) => null);
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(position: Duration.zero));

    if (_audioQueueManager.isAudioQueueMode) {
      _audioQueueManager.isAudioQueueMode = false;
      _audioQueueManager.clearQueueState();
      await _restorePreviousPlayer();
    }


    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.completed,
        controls: [],
      ),
    );
    return super.stop();
  }

  Future<void> playOrPause() async {
    await _player?.playOrPause();
    final playing = _player?.lastState.playing ?? false;
    final position = _player?.lastState.position ?? Duration.zero;
    playbackState.add(playbackState.value.copyWith(
      playing: playing,
      updatePosition: position,
      controls: [playing ? MediaControl.pause : MediaControl.play],
    ));

    if (playing) {
      // Only enable wakelock for video; audio can continue with screen off
      final playBackItem = ref.read(playBackModel.select((value) => value?.item));
      if (playBackItem is! AudioModel) {
        await WakelockPlus.enable();
      }
    } else {
      await WakelockPlus.disable();
    }

    final playerState = _player;
    if (playerState != null) {
      ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(position: position));

      final model = ref.read(playBackModel);
      if (model != null) {
        await _updatePositionWithRetry(model, position, playerState.lastState.playing);
        await _refreshMediaControls(model: model, playing: playing);
      }
    }
  }

  Uri _imageDataToUri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    return Uri.file(path);
  }


  Future<int> setAudioTrack(AudioStreamModel? model, PlaybackModel playbackModel) async =>
      await _player?.setAudioTrack(model, playbackModel) ?? -1;

  Future<int> setSubtitleTrack(SubStreamModel? model, PlaybackModel playbackModel) async =>
      await _player?.setSubtitleTrack(model, playbackModel) ?? -1;

  Future<void> setVolume(double volume) async => _player?.setVolume(volume);

  @override
  Future<void> seek(Duration position) {
    _player?.seek(position);
    if (_player?.lastState.playing == false) {
      ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(position: position));
    }
    return super.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) {
    _player?.setSpeed(speed);
    return super.setSpeed(speed);
  }

  //Native player calls
  @override
  Future<void> loadNextVideo() async {
    final nextVideo = ref.read(playBackModel.select((value) => value?.nextVideo));
    final buffering = ref.read(mediaPlaybackProvider.select((value) => value.buffering));
    if (nextVideo != null && !buffering) ref.read(playbackModelHelper).loadNewVideo(nextVideo);
  }

  @override
  Future<void> loadPreviousVideo() async {
    final previousVideo = ref.read(playBackModel.select((value) => value?.previousVideo));
    final buffering = ref.read(mediaPlaybackProvider.select((value) => value.buffering));
    if (previousVideo != null && !buffering) ref.read(playbackModelHelper).loadNewVideo(previousVideo);
  }

  @override
  void onStop() => stop();

  @override
  void swapAudioTrack(int value) async {
    final playbackModel = ref.read(playBackModel);
    final newModel = await playbackModel?.setAudio(
        playbackModel.audioStreams?.firstWhere((element) => element.index == value), this);
    ref.read(playBackModel.notifier).update((state) => newModel);
    if (newModel != null) {
      await ref.read(playbackModelHelper).shouldReload(newModel);
    }
  }

  @override
  void swapSubtitleTrack(int value) async {
    final playbackModel = ref.read(playBackModel);
    final newModel = await playbackModel?.setSubtitle(
        playbackModel.subStreams?.firstWhere((element) => element.index == value), this);
    ref.read(playBackModel.notifier).update((state) => newModel);
    if (newModel != null) {
      await ref.read(playbackModelHelper).shouldReload(newModel);
    }
  }

  @override
  Future<void> loadProgram(GuideChannel selection) async {
    final channelId = selection.channelId;
    final model = await ref.read(liveTvProvider.notifier).fetchDashboard();
    final channel = model.channels.firstWhereOrNull((c) => c.id == channelId);
    if (channel != null) {
      await ref.read(playbackModelHelper).loadTVChannel(channel);
    }
  }

  @override
  Future<List<GuideProgram>> fetchProgramsForChannel(String channelId) async {
    final channel =
        (await ref.read(jellyApiProvider).usersUserIdItemsItemIdGet(itemId: channelId)).body as ChannelModel;

    final programs = await ref.read(liveTvProvider.notifier).fetchProgramsForChannel(channel);

    final context = ref.read(localizationContextProvider);

    return programs
        .map((p) => GuideProgram(
              id: p.id,
              channelId: channelId,
              name: p.name,
              startMs: p.startDate.millisecondsSinceEpoch,
              endMs: p.endDate.millisecondsSinceEpoch,
              primaryPoster: p.images?.primary?.path,
              overview: p.overview,
              subTitle: context != null ? p.subLabel(context.localized) : null,
            ))
        .toList();
  }

  Future<Uint8List?> takeScreenshot() {
    final player = _player;

    if (player == null) {
      return Future.value(null);
    }

    return player.takeScreenshot();
  }
  Future<void> setShuffleEnabled(bool enabled) async {
    await _audioQueueManager.setShuffleEnabled(enabled);
  }

  Future<void> setAudioRepeatMode(AudioRepeatMode repeatMode) async {
    await _audioQueueManager.setAudioRepeatMode(repeatMode);
  }
  Future<void> loadAudioQueue(List<ItemBaseModel> queue, int initialIndex, Duration startPosition, bool startPlayback) async {
    await _audioQueueManager.loadAudioQueue(queue, initialIndex, startPosition, startPlayback);
  }

  List<ItemBaseModel> audioQueueForDisplay({bool wrapAround = false}) =>
      _audioQueueManager.audioQueueForDisplay(wrapAround: wrapAround);

  int? temporaryQueueStartInDisplay({bool wrapAround = false}) =>
      _audioQueueManager.temporaryQueueStartInDisplay(wrapAround: wrapAround);

  int? temporaryQueueCountInDisplay() =>
      _audioQueueManager.temporaryQueueCountInDisplay();

  Future<void> reorderAudioQueueSection(AudioQueueSection section, int oldIndex, int newIndex) async {
    await _audioQueueManager.reorderAudioQueueSection(section, oldIndex, newIndex);
  }

  Future<void> addToTemporaryQueue(List<ItemBaseModel> items) async {
    await _audioQueueManager.addToTemporaryQueue(items);
  }

  Future<void> clearTemporaryQueue() async {
    _audioQueueManager.clearTemporaryQueue();
  }

  Future<void> removeAudioQueueItem(String itemId) async {
    await _audioQueueManager.removeAudioQueueItem(itemId);
  }

  Future<void> removeAudioQueueSectionItem(AudioQueueSection section, int sectionIndex) async {
    await _audioQueueManager.removeAudioQueueSectionItem(section, sectionIndex);
  }

  Future<void> jumpToQueueItem(ItemBaseModel item) async {
    await _audioQueueManager.jumpToQueueItem(item);
  }
}
