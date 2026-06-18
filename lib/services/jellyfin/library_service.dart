import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/episode_model.dart';
import 'package:fladder/models/items/photos_model.dart';
import 'package:fladder/providers/connectivity_provider.dart';
import 'package:fladder/models/server_query_result.dart';
import 'package:fladder/providers/sync_provider.dart';
import 'package:fladder/providers/user_provider.dart';

class LibraryService {
  final JellyfinOpenApi _api;
  final Ref ref;

  LibraryService(this._api, this.ref);

  Future<Response<ServerQueryResult>> itemsGet({
    String? maxOfficialRating,
    bool? hasThemeSong,
    bool? hasThemeVideo,
    bool? hasSubtitles,
    bool? hasSpecialFeature,
    bool? hasTrailer,
    String? adjacentTo,
    int? parentIndexNumber,
    bool? hasParentalRating,
    bool? isHd,
    bool? is4K,
    List<LocationType>? locationTypes,
    List<LocationType>? excludeLocationTypes,
    bool? isMissing,
    bool? isUnaired,
    num? minCommunityRating,
    num? minCriticRating,
    DateTime? minPremiereDate,
    DateTime? minDateLastSaved,
    DateTime? minDateLastSavedForUser,
    DateTime? maxPremiereDate,
    bool? hasOverview,
    bool? hasImdbId,
    bool? hasTmdbId,
    bool? hasTvdbId,
    bool? isMovie,
    bool? isSeries,
    bool? isNews,
    bool? isKids,
    bool? isSports,
    List<String>? excludeItemIds,
    int? startIndex,
    int? limit,
    bool? recursive,
    String? searchTerm,
    List<SortOrder>? sortOrder,
    String? parentId,
    List<ItemFields>? fields,
    List<BaseItemKind>? excludeItemTypes,
    List<BaseItemKind>? includeItemTypes,
    List<ItemFilter>? filters,
    bool? isFavorite,
    List<MediaType>? mediaTypes,
    List<ImageType>? imageTypes,
    List<ItemSortBy>? sortBy,
    bool? isPlayed,
    List<String>? genres,
    List<String>? officialRatings,
    List<String>? tags,
    List<int>? years,
    bool? enableUserData,
    int? imageTypeLimit,
    List<ImageType>? enableImageTypes,
    String? person,
    List<String>? personIds,
    List<String>? personTypes,
    List<String>? studios,
    List<String>? artists,
    List<String>? excludeArtistIds,
    List<String>? artistIds,
    List<String>? albumArtistIds,
    List<String>? contributingArtistIds,
    List<String>? albums,
    List<String>? albumIds,
    List<String>? ids,
    List<VideoType>? videoTypes,
    String? minOfficialRating,
    bool? isLocked,
    bool? isPlaceHolder,
    bool? hasOfficialRating,
    bool? collapseBoxSetItems,
    int? minWidth,
    int? minHeight,
    int? maxWidth,
    int? maxHeight,
    bool? is3D,
    List<SeriesStatus>? seriesStatus,
    String? nameStartsWithOrGreater,
    String? nameStartsWith,
    String? nameLessThan,
    List<String>? studioIds,
    List<String>? genreIds,
    bool? enableTotalRecordCount,
    bool? enableImages,
  }) async {
    final response = await _api.usersUserIdItemsGet(
      userId: ref.read(userProvider)?.id,
      maxOfficialRating: maxOfficialRating,
      hasThemeSong: hasThemeSong,
      hasThemeVideo: hasThemeVideo,
      hasSubtitles: hasSubtitles,
      hasSpecialFeature: hasSpecialFeature,
      hasTrailer: hasTrailer,
      adjacentTo: adjacentTo,
      parentIndexNumber: parentIndexNumber,
      hasParentalRating: hasParentalRating,
      isHd: isHd,
      is4K: is4K,
      locationTypes: locationTypes,
      excludeLocationTypes: excludeLocationTypes,
      isMissing: isMissing,
      isUnaired: isUnaired,
      minCommunityRating: minCommunityRating,
      minCriticRating: minCriticRating,
      minPremiereDate: minPremiereDate,
      minDateLastSaved: minDateLastSaved,
      minDateLastSavedForUser: minDateLastSavedForUser,
      maxPremiereDate: maxPremiereDate,
      hasOverview: hasOverview,
      hasImdbId: hasImdbId,
      hasTmdbId: hasTmdbId,
      hasTvdbId: hasTvdbId,
      isMovie: isMovie,
      isSeries: isSeries,
      isNews: isNews,
      isKids: isKids,
      isSports: isSports,
      excludeItemIds: excludeItemIds,
      startIndex: startIndex,
      limit: limit,
      recursive: recursive,
      searchTerm: searchTerm,
      sortOrder: sortOrder,
      sortBy: sortBy,
      parentId: parentId,
      fields: {...?fields, ItemFields.candelete, ItemFields.candownload}.toList(),
      excludeItemTypes: excludeItemTypes,
      includeItemTypes: includeItemTypes,
      filters: filters,
      isFavorite: isFavorite,
      mediaTypes: mediaTypes,
      imageTypes: imageTypes,
      isPlayed: isPlayed,
      genres: genres,
      officialRatings: officialRatings,
      tags: tags,
      years: years,
      enableUserData: enableUserData,
      imageTypeLimit: imageTypeLimit,
      enableImageTypes: enableImageTypes,
      person: person,
      personIds: personIds,
      personTypes: personTypes,
      studios: studios,
      artists: artists,
      excludeArtistIds: excludeArtistIds,
      artistIds: artistIds,
      albumArtistIds: albumArtistIds,
      contributingArtistIds: contributingArtistIds,
      albums: albums,
      albumIds: albumIds,
      ids: ids,
      videoTypes: videoTypes,
      minOfficialRating: minOfficialRating,
      isLocked: isLocked,
      isPlaceHolder: isPlaceHolder,
      hasOfficialRating: hasOfficialRating,
      collapseBoxSetItems: collapseBoxSetItems,
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      is3D: is3D,
      seriesStatus: seriesStatus,
      nameStartsWithOrGreater: nameStartsWithOrGreater,
      nameStartsWith: nameStartsWith,
      nameLessThan: nameLessThan,
      studioIds: studioIds,
      genreIds: genreIds,
      enableTotalRecordCount: enableTotalRecordCount,
      enableImages: enableImages,
    );

    final isOffline = ref.read(connectivityStatusProvider.notifier).getConnectivityStates() == ConnectionState.offline;

    if (isOffline) {
      final syncedItems = ref.read(syncProvider).items.where((e) => e.parentId == parentId).toList();

      return Response(
        http.Response("", 202),
        ServerQueryResult.fromBaseQuery(
          BaseItemDtoQueryResult(
            items: syncedItems.map((e) => e.data).nonNulls.toList(),
            totalRecordCount: syncedItems.length,
            startIndex: 0,
          ),
          ref,
        ),
      );
    }

    return response.copyWith(
      body: ServerQueryResult.fromBaseQuery(response.bodyOrThrow, ref),
    );
  }

  Future<List<PhotoModel>> itemsGetAlbumPhotos({
    String? albumId,
  }) async {
    final response = await itemsGet(
      parentId: albumId,
      enableUserData: true,
      fields: [
        ItemFields.parentid,
        ItemFields.datecreated,
      ],
    );
    return response.body?.items.whereType<PhotoModel>().toList() ?? [];
  }

  Future<Response<List<ItemBaseModel>>> personsGet({
    String? searchTerm,
    int? limit,
    bool? isFavorite,
  }) async {
    final response = await _api.personsGet(
      userId: ref.read(userProvider)?.id,
      limit: limit,
      isFavorite: isFavorite,
    );
    return response.copyWith(
      body: response.body?.items
              ?.map(
                (e) => ItemBaseModel.fromBaseDto(e, ref),
              )
              .toList() ??
          [],
    );
  }

  Future<Response<BaseItemDtoQueryResult>> usersUserIdItemsResumeGet({
    int? startIndex,
    int? limit,
    String? searchTerm,
    String? parentId,
    List<ItemFields>? fields,
    List<MediaType>? mediaTypes,
    bool? enableUserData,
    bool? enableTotalRecordCount,
    List<ImageType>? enableImageTypes,
    List<BaseItemKind>? excludeItemTypes,
    List<BaseItemKind>? includeItemTypes,
  }) async {
    return _api.userItemsResumeGet(
      userId: ref.read(userProvider)?.id,
      searchTerm: searchTerm,
      parentId: parentId,
      limit: limit,
      fields: fields,
      mediaTypes: mediaTypes,
      enableTotalRecordCount: enableTotalRecordCount,
      enableImageTypes: enableImageTypes,
      enableUserData: enableUserData,
      includeItemTypes: includeItemTypes,
      excludeItemTypes: excludeItemTypes,
    );
  }

  Future<Response<List<BaseItemDto>>> usersUserIdItemsLatestGet({
    String? parentId,
    List<ItemFields>? fields,
    List<BaseItemKind>? includeItemTypes,
    bool? isPlayed,
    bool? enableImages,
    int? imageTypeLimit,
    List<ImageType>? enableImageTypes,
    bool? enableUserData,
    int? limit,
    bool? groupItems,
  }) async {
    return _api.usersUserIdItemsLatestGet(
      parentId: parentId,
      userId: ref.read(userProvider)?.id,
      fields: fields,
      includeItemTypes: includeItemTypes,
      isPlayed: isPlayed,
      enableImages: enableImages,
      imageTypeLimit: imageTypeLimit,
      enableImageTypes: enableImageTypes,
      enableUserData: enableUserData,
      limit: limit,
      groupItems: groupItems,
    );
  }

  Future<Response<List<RecommendationDto>>> moviesRecommendationsGet({
    String? parentId,
    List<ItemFields>? fields,
    int? categoryLimit,
    int? itemLimit,
  }) async {
    return _api.moviesRecommendationsGet(
      userId: ref.read(userProvider)?.id,
      parentId: parentId,
      fields: fields,
      categoryLimit: categoryLimit,
      itemLimit: itemLimit,
    );
  }

  Future<Response<BaseItemDtoQueryResult>> showsNextUpGet({
    int? startIndex,
    int? limit,
    String? parentId,
    DateTime? nextUpDateCutoff,
    List<ItemFields>? fields,
    bool? enableUserData,
    List<ImageType>? enableImageTypes,
    int? imageTypeLimit,
  }) async {
    return _api.showsNextUpGet(
      userId: ref.read(userProvider)?.id,
      parentId: parentId,
      limit: limit,
      fields: fields,
      enableResumable: false,
      enableRewatching: false,
      disableFirstEpisode: false,
      nextUpDateCutoff: nextUpDateCutoff,
      enableImageTypes: enableImageTypes,
      enableUserData: enableUserData,
      imageTypeLimit: imageTypeLimit,
    );
  }

  Future<Response<BaseItemDtoQueryResult>> genresGet({
    String? parentId,
    List<ItemSortBy>? sortBy,
    List<SortOrder>? sortOrder,
    List<BaseItemKind>? includeItemTypes,
  }) async {
    return _api.genresGet(
      parentId: parentId,
      userId: ref.read(userProvider)?.id,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<Response<BaseItemDtoQueryResult>> showsSeriesIdEpisodesGet({
    required String? seriesId,
    List<ItemFields>? fields,
    int? season,
    String? seasonId,
    bool? isMissing,
    String? adjacentTo,
    String? startItemId,
    int? startIndex,
    int? limit,
    bool? enableImages,
    int? imageTypeLimit,
    List<ImageType>? enableImageTypes,
    bool? enableUserData,
    ShowsSeriesIdEpisodesGetSortBy? sortBy,
  }) async {
    Future<Response<BaseItemDtoQueryResult>> fetchOfflineEpisodes() async {
      final seriesItem = await ref.read(syncProvider.notifier).getSyncedItem(seriesId);
      if (seriesItem != null) {
        final episodes = await ref.read(syncProvider.notifier).getNestedChildren(seriesItem)
          ..where((e) => e.itemModel is EpisodeModel);
        return Response<BaseItemDtoQueryResult>(
          http.Response("", 200),
          BaseItemDtoQueryResult(
            items: episodes.map((e) => e.data).nonNulls.toList(),
            totalRecordCount: episodes.length,
            startIndex: 0,
          ),
        );
      } else {
        return Response<BaseItemDtoQueryResult>(
          http.Response("", 400),
          const BaseItemDtoQueryResult(
            items: [],
            totalRecordCount: 0,
            startIndex: 0,
          ),
        );
      }
    }

    final isoffline = ref.read(connectivityStatusProvider.notifier).getConnectivityStates() == ConnectionState.offline;

    if (isoffline) {
      return fetchOfflineEpisodes();
    }

    try {
      var response = await _api.showsSeriesIdEpisodesGet(
        seriesId: seriesId,
        userId: ref.read(userProvider)?.id,
        fields: [
          ...?fields,
          ItemFields.parentid,
        ],
        isMissing: isMissing,
        limit: limit,
        sortBy: sortBy,
        enableUserData: enableUserData,
        startIndex: startIndex,
        adjacentTo: adjacentTo,
        startItemId: startItemId,
        season: season,
        seasonId: seasonId,
        enableImages: enableImages,
        enableImageTypes: enableImageTypes,
      );
      return response;
    } catch (e) {
      return fetchOfflineEpisodes();
    }
  }

  Future<List<ItemBaseModel>> fetchEpisodeFromShow({
    required String? seriesId,
    String? seasonId,
  }) async {
    final response = await showsSeriesIdEpisodesGet(seriesId: seriesId, seasonId: seasonId);
    return response.body?.items?.map((e) => ItemBaseModel.fromBaseDto(e, ref)).toList() ?? [];
  }

  Future<Response<List<BaseItemDto>>> itemsItemIdSpecialFeaturesGet({required String itemId}) async {
    return _api.itemsItemIdSpecialFeaturesGet(itemId: itemId, userId: ref.read(userProvider)?.id);
  }

  Future<Response<BaseItemDtoQueryResult>> itemsItemIdSimilarGet({
    String? itemId,
    int? limit,
  }) async {
    Future<Response<BaseItemDtoQueryResult>> fetchSimilarGet() async {
      return Response<BaseItemDtoQueryResult>(
        http.Response("", 400),
        const BaseItemDtoQueryResult(
          items: [],
          totalRecordCount: 0,
          startIndex: 0,
        ),
      );
    }

    final isOffline = ref.read(connectivityStatusProvider.notifier).getConnectivityStates() == ConnectionState.offline;

    if (isOffline) {
      return fetchSimilarGet();
    }

    try {
      return await _api.itemsItemIdSimilarGet(userId: ref.read(userProvider)?.id, itemId: itemId, limit: limit, fields: [
        ItemFields.parentid,
        ItemFields.candelete,
        ItemFields.candownload,
      ]);
    } catch (e) {
      return fetchSimilarGet();
    }
  }

  Future<Response<BaseItemDtoQueryResult>> usersUserIdItemsGet({
    String? parentId,
    List<ItemSortBy>? sortBy,
    List<SortOrder>? sortOrder,
    int? limit,
    bool? recursive,
    List<BaseItemKind>? includeItemTypes,
  }) async {
    return _api.usersUserIdItemsGet(
      parentId: parentId,
      userId: ref.read(userProvider)?.id,
      recursive: recursive,
      sortBy: sortBy,
      sortOrder: sortOrder,
      includeItemTypes: includeItemTypes,
      limit: limit,
    );
  }

  Future<Response<BaseItemDtoQueryResult>> usersUserIdViewsGet({
    bool? includeExternalContent,
    List<CollectionType>? presetViews,
    bool? includeHidden,
  }) =>
      _api.userViewsGet(
        userId: ref.read(userProvider)?.id,
        includeExternalContent: includeExternalContent,
        presetViews: presetViews,
        includeHidden: includeHidden,
      );

  Future<Response<List<ExternalIdInfo>>> itemsItemIdExternalIdInfosGet({required String? itemId}) =>
      _api.itemsItemIdExternalIdInfosGet(itemId: itemId);

  Future<Response<List<RemoteSearchResult>>> itemsRemoteSearchSeriesPost(
          {required SeriesInfoRemoteSearchQuery? body}) =>
      _api.itemsRemoteSearchSeriesPost(body: body);

  Future<Response<List<RemoteSearchResult>>> itemsRemoteSearchMoviePost({required MovieInfoRemoteSearchQuery? body}) =>
      _api.itemsRemoteSearchMoviePost(body: body);

  Future<Response<dynamic>> itemsRemoteSearchApplyItemIdPost({
    required String? itemId,
    bool? replaceAllImages,
    required RemoteSearchResult? body,
  }) =>
      _api.itemsRemoteSearchApplyItemIdPost(
        itemId: itemId,
        replaceAllImages: replaceAllImages,
        body: body,
      );

  Future<Response<BaseItemDtoQueryResult>> showsSeriesIdSeasonsGet({
    required String? seriesId,
    bool? enableUserData,
    bool? isMissing,
    List<ItemFields>? fields,
  }) async {
    Future<Response<BaseItemDtoQueryResult>> fetchOfflineSeasons() async {
      final seriesItem = await ref.read(syncProvider.notifier).getSyncedItem(seriesId);
      if (seriesItem != null) {
        final seasons = await ref.read(syncProvider.notifier).getChildren(seriesItem.id);
        return Response<BaseItemDtoQueryResult>(
          http.Response("", 200),
          BaseItemDtoQueryResult(
            items: seasons.map((e) => e.data).nonNulls.toList(),
            totalRecordCount: seasons.length,
            startIndex: 0,
          ),
        );
      } else {
        return Response<BaseItemDtoQueryResult>(
          http.Response("", 400),
          const BaseItemDtoQueryResult(
            items: [],
            totalRecordCount: 0,
            startIndex: 0,
          ),
        );
      }
    }

    final isOffline = ref.read(connectivityStatusProvider.notifier).getConnectivityStates() == ConnectionState.offline;
    if (isOffline) {
      return fetchOfflineSeasons();
    }

    try {
      final response = await _api.showsSeriesIdSeasonsGet(
        seriesId: seriesId,
        isMissing: isMissing,
        enableUserData: enableUserData,
        fields: fields,
      );
      return response;
    } catch (e) {
      return fetchOfflineSeasons();
    }
  }

  Future<Response<QueryFilters>> itemsFilters2Get({
    String? parentId,
    List<BaseItemKind>? includeItemTypes,
    bool? isAiring,
    bool? isMovie,
    bool? isSports,
    bool? isKids,
    bool? isNews,
    bool? isSeries,
    bool? recursive,
  }) =>
      _api.itemsFilters2Get(
        parentId: parentId,
        includeItemTypes: includeItemTypes,
        isAiring: isAiring,
        isMovie: isMovie,
        isSports: isSports,
        isKids: isKids,
        isNews: isNews,
        isSeries: isSeries,
        recursive: recursive,
      );

  Future<Response<BaseItemDtoQueryResult>> studiosGet({
    int? startIndex,
    int? limit,
    String? searchTerm,
    String? parentId,
    List<ItemFields>? fields,
    List<BaseItemKind>? excludeItemTypes,
    List<BaseItemKind>? includeItemTypes,
    bool? isFavorite,
    bool? enableUserData,
    int? imageTypeLimit,
    List<ImageType>? enableImageTypes,
    String? userId,
    String? nameStartsWithOrGreater,
    String? nameStartsWith,
    String? nameLessThan,
    bool? enableImages,
    bool? enableTotalRecordCount,
  }) =>
      _api.studiosGet(
        startIndex: startIndex,
        limit: limit,
        searchTerm: searchTerm,
        parentId: parentId,
        fields: fields,
        excludeItemTypes: excludeItemTypes,
        includeItemTypes: includeItemTypes,
        isFavorite: isFavorite,
        enableUserData: enableUserData,
        imageTypeLimit: imageTypeLimit,
        enableImageTypes: enableImageTypes,
        nameStartsWithOrGreater: nameStartsWithOrGreater,
        nameStartsWith: nameStartsWith,
        nameLessThan: nameLessThan,
        enableImages: enableImages,
        enableTotalRecordCount: enableTotalRecordCount,
      );

  Future<Response<BaseItemDtoQueryResult>> libraryMediaFolders() => _api.libraryMediaFoldersGet();
}
