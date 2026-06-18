import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/audio_model.dart';
import 'package:fladder/models/media_playback_model.dart';
import 'package:fladder/models/playback/audio_prefetch_buffer.dart';
import 'package:fladder/models/playback/audio_url_resolver.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/models/playback/playback_queue_state.dart';
import 'package:fladder/providers/playback_model_helper.dart';
import 'package:fladder/providers/settings/subtitle_settings_provider.dart';
import 'package:fladder/providers/settings/video_player_settings_provider.dart';
import 'package:fladder/providers/video_player_provider.dart';
import 'package:fladder/wrappers/players/base_player.dart';
import 'package:fladder/wrappers/players/player_states.dart';

/// Manages the audio queue lifecycle, crossfading, playlist sync, and
/// queue navigation for audio playback.
///
/// Callbacks inform the owning [MediaControlsWrapper] about setup and UI
/// refresh operations that are outside the manager's direct responsibility.
class AudioQueueManager {
  AudioQueueManager(this.ref);

  final Ref ref;
  BasePlayer? _player;

  // --- State owned by AudioQueueManager ---
  bool isAudioQueueMode = false;
  bool audioQueueTransitioning = false;
  BasePlayer? previousPlayer;

  AudioPrefetchBuffer? _prefetchBuffer;
  List<ItemBaseModel> _mpvPlaylistItems = [];
  int _mpvPlaylistCurrentIndex = 0;
  StreamSubscription<int>? _playlistIndexSub;
  bool _syncingPlaylist = false;
  bool _syncPlaylistPending = false;
  bool _audioQueueRefillInProgress = false;
  bool _audioQueueSourceDepleted = false;
  int _audioQueueNextStartIndex = 0;

  // --- Callbacks (set by MediaControlsWrapper) ---
  /// Called to set up a new [LibMPV] player for audio queue mode.
  /// The callback is responsible for creating and setting up the player.
  Future<void> Function()? onSetupPlayer;

  /// Called to refresh MediaItem / PlaybackState on the system notification.
  Future<void> Function(PlaybackModel model, bool playing)? onRefreshMediaControls;

  /// Called to start playback after loading a queue item.
  Future<void> Function()? onPlay;

  // --- Public API ---

  void attachPlayer(BasePlayer? player) {
    _player = player;
  }

  /// Resets internal queue state without altering [isAudioQueueMode].
  /// Caller is responsible for setting [isAudioQueueMode] and restoring the player.
  void clearQueueState() {
    _playlistIndexSub?.cancel();
    _playlistIndexSub = null;
    _prefetchBuffer?.invalidate();
    _prefetchBuffer = null;
    _mpvPlaylistItems = [];
    _mpvPlaylistCurrentIndex = 0;
    _syncingPlaylist = false;
    _syncPlaylistPending = false;
    _audioQueueRefillInProgress = false;
    _audioQueueSourceDepleted = false;
    _audioQueueNextStartIndex = 0;
  }

  void updateQueueState(PlaybackQueueState Function(PlaybackQueueState) updater) {
    final model = ref.read(playBackModel);
    if (model == null) return;
    ref.read(playBackModel.notifier).update((_) => model.updatePlaybackQueue(updater(model.playbackQueue)));
    unawaited(_syncMpvPlaylist());
  }

  Future<void> loadAudioQueue(
    List<ItemBaseModel> queue,
    int initialIndex,
    Duration startPosition,
    bool startPlayback,
  ) async {
    if (!isAudioQueueMode) {
      previousPlayer = _player;
      await _player?.stop();
      if (onSetupPlayer != null) await onSetupPlayer!();
      isAudioQueueMode = true;
    }

    _playlistIndexSub?.cancel();
    _prefetchBuffer?.invalidate();
    _prefetchBuffer = AudioPrefetchBuffer();
    _mpvPlaylistItems = [];
    _mpvPlaylistCurrentIndex = 0;
    _audioQueueRefillInProgress = false;
    _audioQueueSourceDepleted = false;
    _audioQueueNextStartIndex = queue.length;
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(queueRefilling: false));

    final resolver = AudioUrlResolver(ref);
    final currentItem = queue[initialIndex.clamp(0, queue.length - 1)];
    _prefetchBuffer!.prefetch(queue.sublist(initialIndex.clamp(0, queue.length - 1)), resolver);

    final firstUrl = await _prefetchBuffer!.getUrl(currentItem.id) ?? await AudioUrlResolver(ref).resolve(currentItem);
    _mpvPlaylistItems = [currentItem];

    await _applyReplayGain(currentItem);
    await _player?.loadVideo(firstUrl, false, startPosition: startPosition);
    _player?.applySubtitleSettings(ref.read(subtitleSettingsProvider));

    _playlistIndexSub = (_player is HasPlaylist ? (_player as HasPlaylist).playlistIndexStream : const Stream<int>.empty())
        .listen(_onMpvPlaylistIndexChanged);

    unawaited(_syncMpvPlaylist());

    final playbackModel = ref.read(playBackModel);
    if (playbackModel != null && onRefreshMediaControls != null) {
      await onRefreshMediaControls!(playbackModel, false);
    }

    if (startPlayback && onPlay != null) {
      await onPlay!();
    }
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    final currentId = ref.read(playBackModel)?.item.id;
    updateQueueState((qs) => qs.withShuffleEnabled(enabled, currentId: currentId));
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(shuffleEnabled: enabled));
  }

  Future<void> setAudioRepeatMode(AudioRepeatMode repeatMode) async {
    updateQueueState((qs) => qs.withRepeatMode(repeatMode));
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(repeatMode: repeatMode));
  }

  Future<void> removeAudioQueueItem(String itemId) async {
    updateQueueState((qs) => qs.removeItemById(itemId));
  }

  Future<void> removeAudioQueueSectionItem(AudioQueueSection section, int sectionIndex) async {
    updateQueueState((qs) => qs.removeSectionItem(section, sectionIndex));
  }

  Future<void> reorderAudioQueueSection(AudioQueueSection section, int oldIndex, int newIndex) async {
    updateQueueState((qs) => qs.reorderSection(section, oldIndex, newIndex));
  }

  List<ItemBaseModel> fullAudioQueue() {
    return ref.read(playBackModel)?.playbackQueue.queue ?? const <ItemBaseModel>[];
  }

  Future<void> addToTemporaryQueue(List<ItemBaseModel> items) async {
    if (items.isEmpty) return;
    if (ref.read(playBackModel) == null) {
      await loadAudioQueue(items, 0, Duration.zero, true);
      return;
    }
    updateQueueState((qs) => qs.addToNextUp(items));
  }

  void clearTemporaryQueue() {
    updateQueueState((qs) => qs.clearNextUp());
  }

  /// Handles the audio-queue branch of skipToNext.
  Future<void> skipNext() async {
    if (!isAudioQueueMode) return;
    final wasRepeatOne = await _disableRepeatOneForSkip();
    if (!wasRepeatOne &&
        _player is HasPlaylist &&
        _isMpvPlaylistInSync() &&
        _mpvPlaylistItems.length > _mpvPlaylistCurrentIndex + 1) {
      final current = _mpvPlaylistItems[_mpvPlaylistCurrentIndex];
      final next = _mpvPlaylistItems[_mpvPlaylistCurrentIndex + 1];
      if (!_shouldCrossfade(current, next, manual: true)) {
        await (_player as HasPlaylist).playerNext();
        return;
      }
    }
    await _playNextQueueItem(manual: true);
  }

  /// Handles the audio-queue branch of skipToPrevious.
  Future<void> skipPrevious() async {
    if (!isAudioQueueMode) return;
    if (_player?.lastState.position != null && _player!.lastState.position >= const Duration(seconds: 3)) {
      await _player?.seek(Duration.zero);
      return;
    }
    final wasRepeatOne = await _disableRepeatOneForSkip();
    if (!wasRepeatOne && _player is HasPlaylist && _isMpvPlaylistInSync() && _mpvPlaylistCurrentIndex > 0) {
      final current = _mpvPlaylistItems[_mpvPlaylistCurrentIndex];
      final previous = _mpvPlaylistItems[_mpvPlaylistCurrentIndex - 1];
      if (!_shouldCrossfade(current, previous, manual: true)) {
        await (_player as HasPlaylist).playerPrevious();
        return;
      }
    }
    await _playPreviousQueueItem();
  }

  Future<void> jumpToQueueItem(ItemBaseModel item) async {
    await _withQueueTransition(() async {
      final playbackModel = ref.read(playBackModel);
      if (playbackModel == null) return;

      final newQueueState = playbackModel.playbackQueue.jumpToItem(item.id);

      await _applyQueueItem(item, newQueueState, playbackModel, Duration.zero);
    });
    await _syncMpvPlaylist();
  }

  int? temporaryQueueStartInDisplay({bool wrapAround = false}) {
    final playbackModel = ref.read(playBackModel);
    return playbackModel?.playbackQueue.nextUpStartInDisplay(playbackModel.item.id);
  }

  int? temporaryQueueCountInDisplay() {
    final playbackModel = ref.read(playBackModel);
    return playbackModel?.playbackQueue.nextUpCountInDisplay(playbackModel.item.id);
  }

  List<ItemBaseModel> audioQueueForDisplay({bool wrapAround = false}) {
    final playbackModel = ref.read(playBackModel);
    if (playbackModel == null || playbackModel.playbackQueue.queue.isEmpty) {
      return const <ItemBaseModel>[];
    }
    return playbackModel.playbackQueue.queueForDisplay(playbackModel.item.id, wrapAround: wrapAround);
  }
  // --- Internal helpers ---

  Future<void> _applyReplayGain(ItemBaseModel item) async {
    if (_player is AudioQueueCapable) await (_player as AudioQueueCapable).applyReplayGainForItem(item);
  }

  Future<void> _withQueueTransition(Future<void> Function() op) async {
    if (audioQueueTransitioning) return;
    audioQueueTransitioning = true;
    try {
      await op();
    } catch (error, stackTrace) {
      log('Queue transition error: $error\n$stackTrace');
    } finally {
      audioQueueTransitioning = false;
    }
  }

  Future<void> _onAudioTrackCompleted() async {
    final remainingItems = _mpvPlaylistItems.length - _mpvPlaylistCurrentIndex - 1;
    if (remainingItems > 0) return;
    final playbackModel = ref.read(playBackModel);
    if (playbackModel == null || !isAudioQueueMode) return;

    if (playbackModel.playbackQueue.repeatMode == AudioRepeatMode.one) {
      await _withQueueTransition(() async {
        await _applyReplayGain(playbackModel.item);
        await _player?.loadVideo(await AudioUrlResolver(ref).resolve(playbackModel.item), true);
      });
      return;
    }

    await _playNextQueueItem();
  }

  /// Called from [MediaControlsWrapper._subscribePlayer] when a track completes.
  void onTrackCompleted() {
    if (!audioQueueTransitioning) {
      unawaited(_onAudioTrackCompleted());
    }
  }

  Future<void> _playNextQueueItem({Duration startPosition = Duration.zero, bool manual = false}) async {
    await _withQueueTransition(() async {
      final playbackModel = ref.read(playBackModel);
      if (playbackModel == null) return;
      final fromId = playbackModel.item.id;
      final transition = playbackModel.playbackQueue.nextTransition(fromId);
      if (transition == null) return;
      await _applyQueueItem(transition.item, transition.state, playbackModel, startPosition, manual: manual);
    });
    await _syncMpvPlaylist();
  }

  Future<void> _playPreviousQueueItem() async {
    await _withQueueTransition(() async {
      final playbackModel = ref.read(playBackModel);
      if (playbackModel == null) return;
      final transition = playbackModel.playbackQueue.previousTransition(playbackModel.item.id);
      if (transition == null) {
        await _player?.seek(Duration.zero);
        return;
      }
      await _applyQueueItem(transition.item, transition.state, playbackModel, Duration.zero, manual: true);
    });
    await _syncMpvPlaylist();
  }

  bool _shouldCrossfade(ItemBaseModel current, ItemBaseModel next, {bool manual = false}) {
    if (!ref.read(videoPlayerSettingsProvider).enableCrossfade) return false;
    if (manual) return true;
    if (current is! AudioModel || next is! AudioModel) return false;
    final currentAlbumId = current.albumId;
    final nextAlbumId = next.albumId;
    if (currentAlbumId == null || currentAlbumId.isEmpty) return true;
    if (currentAlbumId != nextAlbumId) return true;
    final currentTrack = current.trackNumber;
    final nextTrack = next.trackNumber;
    if (currentTrack == null || nextTrack == null || currentTrack <= 0 || nextTrack <= 0) return true;
    return nextTrack != currentTrack + 1;
  }

  Future<void> _applyQueueItem(
    ItemBaseModel item,
    PlaybackQueueState newQueueState,
    PlaybackModel currentModel,
    Duration startPosition, {
    bool load = true,
    bool manual = false,
  }) async {
    final isChangingItem = currentModel.item.id != item.id;
    if (isChangingItem) {
      final stopPosition = _player?.lastState.position ?? Duration.zero;
      final stopDuration = _player?.lastState.duration ?? currentModel.item.overview.runTime;
      await currentModel.playbackStopped(stopPosition, stopDuration, ref);
    }

    final nextModel = await ref.read(playbackModelHelper).createPlaybackModel(
          null,
          item,
          oldModel: currentModel,
          libraryQueue: newQueueState.queue,
          showPlaybackOptions: false,
          startPosition: startPosition,
        );
    if (nextModel == null) return;

    final latestNextUpQueue = ref.read(playBackModel)?.playbackQueue.nextUpQueue ?? const [];
    final originalNextUpQueue = currentModel.playbackQueue.nextUpQueue;
    final concurrentItems = latestNextUpQueue.where((e) => !originalNextUpQueue.any((q) => q.id == e.id)).toList();
    final mergedQueueState = concurrentItems.isNotEmpty
        ? newQueueState.copyWith(nextUpQueue: [...newQueueState.nextUpQueue, ...concurrentItems])
        : newQueueState;

    final updatedModel = nextModel.updatePlaybackQueue(mergedQueueState);
    ref.read(playBackModel.notifier).update((_) => updatedModel);

    if (load) {
      final url = updatedModel.media?.url ?? '';
      if (isAudioQueueMode && _player is AudioQueueCapable && _shouldCrossfade(currentModel.item, item, manual: manual)) {
        final capablePlayer = _player as AudioQueueCapable;
        double? gainDb;
        if (item is AudioModel) {
          final gain = item.normalizationGain;
          if (gain != null && !gain.isNaN && !gain.isInfinite) {
            gainDb = gain.clamp(-60.0, 20.0).toDouble();
          }
        }
        await capablePlayer.crossfadeToUrl(url, startPosition, replayGainDb: gainDb);
        _playlistIndexSub?.cancel();
        if (_player is HasPlaylist) {
          _playlistIndexSub = (_player as HasPlaylist).playlistIndexStream.listen(_onMpvPlaylistIndexChanged);
        }
      } else {
        await _applyReplayGain(item);
        await _player?.loadVideo(url, true, startPosition: startPosition);
      }
      _player?.applySubtitleSettings(ref.read(subtitleSettingsProvider));
      if (_player is HasPlaylist) {
        _mpvPlaylistItems = [item];
        _mpvPlaylistCurrentIndex = 0;
      }
    }

    await updatedModel.playbackStarted(startPosition, ref);
    if (onRefreshMediaControls != null) {
      await onRefreshMediaControls!(updatedModel, true);
    }
  }

  void _onMpvPlaylistIndexChanged(int newIndex) {
    if (!isAudioQueueMode) return;
    if (newIndex < 0 || newIndex >= _mpvPlaylistItems.length || newIndex == _mpvPlaylistCurrentIndex) return;

    _mpvPlaylistCurrentIndex = newIndex;
    if (audioQueueTransitioning) {
      unawaited(_syncMpvPlaylist());
      return;
    }

    unawaited(_withQueueTransition(() async {
      final playbackModel = ref.read(playBackModel);
      if (playbackModel == null) return;
      final newItem = _mpvPlaylistItems[newIndex];
      final fromId = playbackModel.item.id;
      final newQueueState = playbackModel.playbackQueue.advanceFromCurrentTo(fromId, newItem.id);
      await _applyQueueItem(newItem, newQueueState, playbackModel, Duration.zero, load: false);
    }));
    unawaited(_syncMpvPlaylist());
  }

  Future<void> _syncMpvPlaylist() async {
    if (_syncingPlaylist) {
      _syncPlaylistPending = true;
      return;
    }
    if (!isAudioQueueMode || _player is! HasPlaylist) return;
    _syncingPlaylist = true;
    try {
      final playbackModel = ref.read(playBackModel);
      if (playbackModel == null) return;
      final player = _player as HasPlaylist;

      if (_mpvPlaylistItems.isEmpty) {
        _mpvPlaylistCurrentIndex = 0;
        return;
      }
      if (_mpvPlaylistCurrentIndex >= _mpvPlaylistItems.length) {
        _mpvPlaylistCurrentIndex = _mpvPlaylistItems.length - 1;
      }

      for (var i = _mpvPlaylistItems.length - 1; i > _mpvPlaylistCurrentIndex; i--) {
        await player.removeFromPlaylist(i);
      }
      _mpvPlaylistItems = _mpvPlaylistItems.sublist(0, _mpvPlaylistCurrentIndex + 1);

      if (playbackModel.playbackQueue.repeatMode == AudioRepeatMode.one) return;

      final buffer = _prefetchBuffer;
      if (buffer == null) return;
      await _tryRefillAudioQueue(playbackModel, buffer.bufferSize);

      final refreshedModel = ref.read(playBackModel);
      if (refreshedModel == null) return;
      final resolver = AudioUrlResolver(ref);
      final queued = <String>{};

      for (final item in refreshedModel.playbackQueue.queueAheadForPrefetch()) {
        if (queued.contains(item.id)) continue;
        if (_mpvPlaylistItems.length - _mpvPlaylistCurrentIndex - 1 >= buffer.bufferSize) break;

        buffer.prefetch([item], resolver);
        final url = await buffer.getUrl(item.id);
        if (url == null || url.isEmpty) break;

        await player.addToPlaylist(url);
        _mpvPlaylistItems.add(item);
        queued.add(item.id);
      }
    } finally {
      _syncingPlaylist = false;
      if (_syncPlaylistPending) {
        _syncPlaylistPending = false;
        unawaited(_syncMpvPlaylist());
      }
    }
  }

  Future<void> _tryRefillAudioQueue(PlaybackModel playbackModel, int bufferSize) async {
    final queueSource = playbackModel.queueSource;
    if (queueSource == null || !queueSource.supportsRefill) return;
    if (_audioQueueRefillInProgress || _audioQueueSourceDepleted) return;

    final remaining = playbackModel.playbackQueue.queueAheadForPrefetch().length;
    if (remaining > bufferSize) return;

    _audioQueueRefillInProgress = true;
    ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(queueRefilling: true));
    try {
      final fetchedItems = await queueSource.fetchQueue(
        ref.read,
        limit: queueSource.limit,
        startIndex: _audioQueueNextStartIndex,
      );
      _audioQueueNextStartIndex += fetchedItems.length.toInt();
      if (fetchedItems.isEmpty) {
        _audioQueueSourceDepleted = true;
        return;
      }

      final currentModel = ref.read(playBackModel);
      if (currentModel == null) return;
      final updatedModel = currentModel.updatePlaybackQueue(
        currentModel.playbackQueue.appendToQueue(fetchedItems),
      );
      ref.read(playBackModel.notifier).update((_) => updatedModel);
    } catch (error, stackTrace) {
      log('Audio queue refill failed: $error\n$stackTrace');
    } finally {
      _audioQueueRefillInProgress = false;
      ref.read(mediaPlaybackProvider.notifier).update((state) => state.copyWith(queueRefilling: false));
    }
  }

  Future<bool> _disableRepeatOneForSkip() async {
    final playbackModel = ref.read(playBackModel);
    if (playbackModel?.playbackQueue.repeatMode == AudioRepeatMode.one) {
      await setAudioRepeatMode(AudioRepeatMode.all);
      return true;
    }
    return false;
  }

  bool _isMpvPlaylistInSync() {
    final playbackModel = ref.read(playBackModel);
    if (playbackModel == null) return false;
    if (_mpvPlaylistItems.isEmpty) return false;
    if (_mpvPlaylistCurrentIndex < 0 || _mpvPlaylistCurrentIndex >= _mpvPlaylistItems.length) return false;
    return _mpvPlaylistItems[_mpvPlaylistCurrentIndex].id == playbackModel.item.id;
  }
}
