import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chopper/chopper.dart';
import 'package:fladder/providers/api_provider.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/items/episode_model.dart';
import 'package:fladder/providers/service_provider.dart';

/// Narrow interface for library browsing operations.
///
/// Wraps [JellyService] methods that deal with browsing, filtering, and
/// searching the media library. Consumers get a focused contract instead
/// of the full 60-method [JellyService] surface.
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.read(jellyApiProvider));
});

class LibraryRepository {
  final JellyService _api;
  LibraryRepository(this._api);

  Future<Response<ServerQueryResult>> browse({
    String? parentId,
    int? startIndex,
    int? limit,
    List<BaseItemKind>? includeItemTypes,
    List<BaseItemKind>? excludeItemTypes,
    List<ItemFilter>? filters,
    List<ItemSortBy>? sortBy,
    List<SortOrder>? sortOrder,
    bool? recursive,
    String? searchTerm,
  }) =>
      _api.itemsGet(
        parentId: parentId,
        startIndex: startIndex,
        limit: limit,
        includeItemTypes: includeItemTypes,
        excludeItemTypes: excludeItemTypes,
        filters: filters,
        sortBy: sortBy,
        sortOrder: sortOrder,
        recursive: recursive,
        searchTerm: searchTerm,
      );

  Future<Response<BaseItemDtoQueryResult>> resume({
    int? limit,
    List<MediaType>? mediaTypes,
    List<BaseItemKind>? includeItemTypes,
  }) =>
      _api.usersUserIdItemsResumeGet(
        limit: limit,
        mediaTypes: mediaTypes,
        includeItemTypes: includeItemTypes,
      );

  Future<Response<List<BaseItemDto>>> latest({
    String? parentId,
    List<BaseItemKind>? includeItemTypes,
    int? limit,
  }) =>
      _api.usersUserIdItemsLatestGet(
        parentId: parentId,
        includeItemTypes: includeItemTypes,
        limit: limit,
      );

  Future<Response<List<RecommendationDto>>> recommendations({
    String? parentId,
    int? categoryLimit,
    int? itemLimit,
  }) =>
      _api.moviesRecommendationsGet(
        parentId: parentId,
        categoryLimit: categoryLimit,
        itemLimit: itemLimit,
      );

  Future<Response<BaseItemDtoQueryResult>> nextUp({
    int? limit,
    String? parentId,
    List<ItemFields>? fields,
  }) =>
      _api.showsNextUpGet(
        limit: limit,
        parentId: parentId,
        fields: fields,
      );

  Future<Response<List<EpisodeModel>>> episodes({
    required String seriesId,
    String? seasonId,
  }) async {
    final response = await _api.showsSeriesIdEpisodesGet(
      seriesId: seriesId,
      seasonId: seasonId,
    );
    return _api.fetchEpisodeFromShow(seriesId: seriesId, seasonId: seasonId).then(
          (items) => Response<List<EpisodeModel>>(response.base, items.map((e) => e as EpisodeModel).toList()),
        );
  }

  Future<Response<BaseItemDtoQueryResult>> seasons({
    required String seriesId,
    bool? isMissing,
    List<ItemFields>? fields,
  }) =>
      _api.showsSeriesIdSeasonsGet(
        seriesId: seriesId,
        isMissing: isMissing,
        fields: fields,
      );
}
