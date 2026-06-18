import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart' as enums;
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/media_segments_model.dart';
import 'package:fladder/models/items/trick_play_model.dart';
import 'package:fladder/providers/api_provider.dart';
import 'package:fladder/providers/auth_provider.dart';
import 'package:fladder/models/server_query_result.dart';
import 'package:fladder/providers/sync_provider.dart';
import 'package:fladder/providers/user_provider.dart';

class PlaybackService {
  final JellyfinOpenApi _api;
  final Ref ref;

  PlaybackService(this._api, this.ref);

  Future<Response> sessionsPlayingPost({required PlaybackStartInfo? body}) async => _api.sessionsPlayingPost(body: body);

  Future<Response> sessionsPlayingStoppedPost({
    required PlaybackStopInfo? body,
  }) {
    final positionTicks = body?.positionTicks;
    if (positionTicks != null) {
      ref
          .read(syncProvider.notifier)
          .updatePlaybackPosition(itemId: body?.itemId, position: Duration(milliseconds: positionTicks ~/ 10000));
    }
    return _api.sessionsPlayingStoppedPost(body: body);
  }

  Future<Response> sessionsPlayingProgressPost({required PlaybackProgressInfo? body}) async =>
      _api.sessionsPlayingProgressPost(body: body);

  Future<Response<PlaybackInfoResponse>> itemsItemIdPlaybackInfoPost({
    required String? itemId,
    required PlaybackInfoDto? body,
  }) async =>
      _api.itemsItemIdPlaybackInfoPost(
        itemId: itemId,
        userId: ref.read(userProvider)?.id,
        enableDirectPlay: body?.enableDirectPlay,
        enableDirectStream: body?.enableDirectStream,
        enableTranscoding: body?.enableTranscoding,
        autoOpenLiveStream: body?.autoOpenLiveStream,
        maxStreamingBitrate: body?.maxStreamingBitrate,
        liveStreamId: body?.liveStreamId,
        startTimeTicks: body?.startTimeTicks,
        mediaSourceId: body?.mediaSourceId,
        audioStreamIndex: body?.audioStreamIndex,
        subtitleStreamIndex: body?.subtitleStreamIndex,
        body: body,
      );

  //VideosItemsStreamGet
  Future<Response<String>> videoStreamGet(
    String? itemId,
    String? container,
    int? maxHeight,
    int? maxBitRate,
  ) async {
    var response = await _api.videosItemIdStreamContainerGet(
      itemId: itemId,
      container: container,
      enableAudioVbrEncoding: true,
      enableAutoStreamCopy: true,
      maxHeight: maxHeight,
      videoBitRate: maxBitRate,
      subtitleMethod: VideosItemIdStreamContainerGetSubtitleMethod.embed,
    );
    return response;
  }

  Future<Response<MediaSegmentsModel>?> mediaSegmentsGet({
    required String id,
  }) async {
    try {
      final response = await _api.mediaSegmentsItemIdGet(itemId: id);
      final newSegments = response.body?.items?.map((e) => e.toSegment).toList() ?? [];
      return response.copyWith(
        body: MediaSegmentsModel(segments: newSegments),
      );
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<Response<TrickPlayModel>?> getTrickPlay({
    required ItemBaseModel? item,
    int? width,
    required Ref ref,
  }) async {
    try {
      if (item == null) return null;
      if (item.overview.trickPlayInfo?.isEmpty == true) {
        return null;
      }
      final trickPlayModel = item.overview.trickPlayInfo?.values.lastOrNull;
      if (trickPlayModel == null) return null;
      final response = await _api.videosItemIdTrickplayWidthTilesM3u8Get(
        itemId: item.id,
        width: trickPlayModel.width,
      );

      final server = ref.read(serverUrlProvider);

      if (server == null) return null;

      final sanitizedUrls = response.bodyString
          .split('\n')
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .map((line) => line.trim())
          .map((line) => Uri.parse(line).toString())
          .toList();

      return response.copyWith(
          body: trickPlayModel.copyWith(
              images: sanitizedUrls
                  .map(
                    (e) {
                      final parsed = Uri.tryParse(e);
                      if (parsed == null) return '';
                      if (parsed.hasScheme && parsed.host.isNotEmpty) return parsed.toString();
                      return buildServerUrl(
                        ref,
                        pathSegments: [
                          'Videos',
                          item.id,
                          'Trickplay',
                          trickPlayModel.width.toString(),
                          ...parsed.pathSegments.where((s) => s.isNotEmpty),
                        ],
                        queryParameters: parsed.queryParameters.isNotEmpty
                            ? {for (final entry in parsed.queryParameters.entries) entry.key: entry.value}
                            : null,
                      );
                    },
                  )
                  .where((e) => e.isNotEmpty)
                  .toList()));
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<Response<List<SessionInfoDto>>> sessionsInfo(String deviceId) async => _api.sessionsGet(deviceId: deviceId);

  Future<Response<ServerQueryResult>> albumInstantMixGet({
    required String itemId,
    int? limit,
  }) async {
    final response = await _api.albumsItemIdInstantMixGet(
      userId: ref.read(userProvider)?.id,
      itemId: itemId,
      limit: limit,
      fields: [ItemFields.primaryimageaspectratio, ItemFields.mediasources, ItemFields.mediastreams],
      enableImages: true,
      enableUserData: true,
      imageTypeLimit: 1,
      enableImageTypes: [ImageType.primary],
    );
    return response.copyWith(
      body: ServerQueryResult.fromBaseQuery(response.bodyOrThrow, ref),
    );
  }

  Future<Response<ServerQueryResult>> artistInstantMixGet({
    required String itemId,
    int? limit,
  }) async {
    final response = await _api.artistsItemIdInstantMixGet(
      userId: ref.read(userProvider)?.id,
      itemId: itemId,
      limit: limit,
      fields: [ItemFields.primaryimageaspectratio, ItemFields.mediasources, ItemFields.mediastreams],
      enableImages: true,
      enableUserData: true,
      imageTypeLimit: 1,
      enableImageTypes: [ImageType.primary],
    );
    return response.copyWith(
      body: ServerQueryResult.fromBaseQuery(response.bodyOrThrow, ref),
    );
  }

  Future<Response<ServerQueryResult>> audioInstantMixGet({
    required String itemId,
    int? limit,
  }) async {
    final response = await _api.songsItemIdInstantMixGet(
      userId: ref.read(userProvider)?.id,
      itemId: itemId,
      limit: limit,
      fields: [ItemFields.primaryimageaspectratio, ItemFields.mediasources, ItemFields.mediastreams],
      enableImages: true,
      enableUserData: true,
      imageTypeLimit: 1,
      enableImageTypes: [ImageType.primary],
    );
    return response.copyWith(
      body: ServerQueryResult.fromBaseQuery(response.bodyOrThrow, ref),
    );
  }

  Future<Response<ServerQueryResult>> playlistsPlaylistIdItemsGet({
    required String? playlistId,
    int? startIndex,
    int? limit,
    List<ItemFields>? fields,
    bool? enableImages,
    bool? enableUserData,
    int? imageTypeLimit,
    List<ImageType>? enableImageTypes,
  }) async {
    final response = await _api.playlistsPlaylistIdItemsGet(
      playlistId: playlistId,
      userId: ref.read(userProvider)?.id,
      startIndex: startIndex,
      limit: limit,
      fields: fields,
      enableImages: enableImages,
      enableUserData: enableUserData,
      imageTypeLimit: imageTypeLimit,
      enableImageTypes: enableImageTypes,
    );
    return response.copyWith(
      body: ServerQueryResult.fromBaseQuery(response.bodyOrThrow, ref),
    );
  }

  Future<Response> playlistsPlaylistIdItemsDelete({required String? playlistId, List<String>? entryIds}) =>
      _api.playlistsPlaylistIdItemsDelete(
        playlistId: playlistId,
        entryIds: entryIds,
      );

  Future<Response<dynamic>> playlistsPost({
    String? name,
    List<String>? ids,
    required CreatePlaylistDto? body,
  }) async {
    return _api.playlistsPost(
      name: name,
      ids: ids,
      userId: ref.read(userProvider)?.id,
      body: body,
    );
  }

  Future<Response<dynamic>> playlistsPlaylistIdItemsPost({
    String? playlistId,
    List<String>? ids,
  }) async {
    return _api.playlistsPlaylistIdItemsPost(
      playlistId: playlistId,
      ids: ids,
      userId: ref.read(userProvider)?.id,
    );
  }

  /// Builds the URL for video streaming without making the HTTP request
  String buildVideoStreamUrl({
    required String itemId,
    required String container,
    bool? $static,
    String? params,
    String? tag,
    String? deviceProfileId,
    String? playSessionId,
    String? segmentContainer,
    int? segmentLength,
    int? minSegments,
    String? mediaSourceId,
    String? deviceId,
    String? audioCodec,
    bool? enableAutoStreamCopy,
    bool? allowVideoStreamCopy,
    bool? allowAudioStreamCopy,
    bool? breakOnNonKeyFrames,
    int? audioSampleRate,
    int? maxAudioBitDepth,
    int? audioBitRate,
    int? audioChannels,
    int? maxAudioChannels,
    String? profile,
    String? level,
    num? framerate,
    num? maxFramerate,
    bool? copyTimestamps,
    int? startTimeTicks,
    int? width,
    int? height,
    int? maxWidth,
    int? maxHeight,
    int? videoBitRate,
    int? subtitleStreamIndex,
    enums.VideosItemIdStreamContainerGetSubtitleMethod? subtitleMethod,
    int? maxRefFrames,
    int? maxVideoBitDepth,
    bool? requireAvc,
    bool? deInterlace,
    bool? requireNonAnamorphic,
    int? transcodingMaxAudioChannels,
    int? cpuCoreLimit,
    String? liveStreamId,
    bool? enableMpegtsM2TsMode,
    String? videoCodec,
    String? subtitleCodec,
    String? transcodeReasons,
    int? audioStreamIndex,
    int? videoStreamIndex,
    enums.VideosItemIdStreamContainerGetContext? context,
    Object? streamOptions,
    bool? enableAudioVbrEncoding,
  }) {
    final serverUrl =
        ref.read(authProvider).serverLoginModel?.tempCredentials.url ?? ref.read(userProvider)?.credentials.url ?? '';

    final baseUrl = serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;
    final path = '/Videos/$itemId/stream.$container';

    // Build query parameters
    final queryParams = <String, String>{};

    if ($static != null) queryParams['static'] = $static.toString();
    if (params != null) queryParams['params'] = params;
    if (tag != null) queryParams['tag'] = tag;
    if (deviceProfileId != null) queryParams['deviceProfileId'] = deviceProfileId;
    if (playSessionId != null) queryParams['playSessionId'] = playSessionId;
    if (segmentContainer != null) queryParams['segmentContainer'] = segmentContainer;
    if (segmentLength != null) queryParams['segmentLength'] = segmentLength.toString();
    if (minSegments != null) queryParams['minSegments'] = minSegments.toString();
    if (mediaSourceId != null) queryParams['mediaSourceId'] = mediaSourceId;
    if (deviceId != null) queryParams['deviceId'] = deviceId;
    if (audioCodec != null) queryParams['audioCodec'] = audioCodec;
    if (enableAutoStreamCopy != null) queryParams['enableAutoStreamCopy'] = enableAutoStreamCopy.toString();
    if (allowVideoStreamCopy != null) queryParams['allowVideoStreamCopy'] = allowVideoStreamCopy.toString();
    if (allowAudioStreamCopy != null) queryParams['allowAudioStreamCopy'] = allowAudioStreamCopy.toString();
    if (breakOnNonKeyFrames != null) queryParams['breakOnNonKeyFrames'] = breakOnNonKeyFrames.toString();
    if (audioSampleRate != null) queryParams['audioSampleRate'] = audioSampleRate.toString();
    if (maxAudioBitDepth != null) queryParams['maxAudioBitDepth'] = maxAudioBitDepth.toString();
    if (audioBitRate != null) queryParams['audioBitRate'] = audioBitRate.toString();
    if (audioChannels != null) queryParams['audioChannels'] = audioChannels.toString();
    if (maxAudioChannels != null) queryParams['maxAudioChannels'] = maxAudioChannels.toString();
    if (profile != null) queryParams['profile'] = profile;
    if (level != null) queryParams['level'] = level;
    if (framerate != null) queryParams['framerate'] = framerate.toString();
    if (maxFramerate != null) queryParams['maxFramerate'] = maxFramerate.toString();
    if (copyTimestamps != null) queryParams['copyTimestamps'] = copyTimestamps.toString();
    if (startTimeTicks != null) queryParams['startTimeTicks'] = startTimeTicks.toString();
    if (width != null) queryParams['width'] = width.toString();
    if (height != null) queryParams['height'] = height.toString();
    if (maxWidth != null) queryParams['maxWidth'] = maxWidth.toString();
    if (maxHeight != null) queryParams['maxHeight'] = maxHeight.toString();
    if (videoBitRate != null) queryParams['videoBitRate'] = videoBitRate.toString();
    if (subtitleStreamIndex != null) queryParams['subtitleStreamIndex'] = subtitleStreamIndex.toString();
    if (subtitleMethod != null) queryParams['subtitleMethod'] = subtitleMethod.value.toString();
    if (maxRefFrames != null) queryParams['maxRefFrames'] = maxRefFrames.toString();
    if (maxVideoBitDepth != null) queryParams['maxVideoBitDepth'] = maxVideoBitDepth.toString();
    if (requireAvc != null) queryParams['requireAvc'] = requireAvc.toString();
    if (deInterlace != null) queryParams['deInterlace'] = deInterlace.toString();
    if (requireNonAnamorphic != null) queryParams['requireNonAnamorphic'] = requireNonAnamorphic.toString();
    if (transcodingMaxAudioChannels != null) {
      queryParams['transcodingMaxAudioChannels'] = transcodingMaxAudioChannels.toString();
    }
    if (cpuCoreLimit != null) queryParams['cpuCoreLimit'] = cpuCoreLimit.toString();
    if (liveStreamId != null) queryParams['liveStreamId'] = liveStreamId;
    if (enableMpegtsM2TsMode != null) queryParams['enableMpegtsM2TsMode'] = enableMpegtsM2TsMode.toString();
    if (videoCodec != null) queryParams['videoCodec'] = videoCodec;
    if (subtitleCodec != null) queryParams['subtitleCodec'] = subtitleCodec;
    if (transcodeReasons != null) queryParams['transcodeReasons'] = transcodeReasons;
    if (audioStreamIndex != null) queryParams['audioStreamIndex'] = audioStreamIndex.toString();
    if (videoStreamIndex != null) queryParams['videoStreamIndex'] = videoStreamIndex.toString();
    if (context != null) queryParams['context'] = context.value.toString();
    if (streamOptions != null) queryParams['streamOptions'] = streamOptions.toString();
    if (enableAudioVbrEncoding != null) queryParams['enableAudioVbrEncoding'] = enableAudioVbrEncoding.toString();

    // Build the query string
    final queryString =
        queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');

    return queryString.isEmpty ? '$baseUrl$path' : '$baseUrl$path?$queryString';
  }
}
