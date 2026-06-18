
import 'package:flutter/foundation.dart';

import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/fake/fake_jellyfin_open_api.dart';
import 'package:fladder/jellyfin/enum_models.dart';
import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart' as enums;
import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/account_model.dart';
import 'package:fladder/models/credentials_model.dart';
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/server_query_result.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/models/items/media_segments_model.dart';
import 'package:fladder/models/items/photos_model.dart';
import 'package:fladder/models/items/trick_play_model.dart';
import 'package:fladder/providers/auth_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/services/jellyfin/auth_service.dart';
import 'package:fladder/services/jellyfin/admin_service.dart';
import 'package:fladder/services/jellyfin/library_service.dart';
import 'package:fladder/services/jellyfin/live_tv_service.dart';
import 'package:fladder/services/jellyfin/playback_service.dart';
import 'package:fladder/services/jellyfin/system_service.dart';
import 'package:fladder/services/jellyfin/user_service.dart';



class JellyService {
  JellyService(this.ref, this._api)
    : library = LibraryService(_api, ref),
      playback = PlaybackService(_api, ref),
      user = UserService(_api, ref),
      auth = AuthService(_api, ref),
      system = SystemService(_api, ref),
      admin = AdminService(_api, ref),
      liveTv = LiveTvService(_api, ref);

  final JellyfinOpenApi _api;
  final LibraryService library;
  final PlaybackService playback;
  final UserService user;
  final AuthService auth;
  final SystemService system;
  final AdminService admin;
  final LiveTvService liveTv;

  JellyfinOpenApi get api {
    var authServer = ref.read(authProvider).serverLoginModel?.tempCredentials.url ?? "";
    var currentServer = ref.read(userProvider)?.credentials.url;
    if ((authServer.isNotEmpty ? authServer : currentServer) == FakeHelper.fakeTestServerUrl) {
      return FakeJellyfinOpenApi();
    } else {
      return _api;
    }
  }

  final Ref ref;
  AccountModel? get account => ref.read(userProvider);


  Future<Response<ItemBaseModel>> usersUserIdItemsItemIdGet({
    String? itemId,
  }) async =>
      user.usersUserIdItemsItemIdGet(itemId: itemId);

  Future<Response<BaseItemDto>> usersUserIdItemsItemIdGetBaseItem({
    String? itemId,
  }) async =>
      user.usersUserIdItemsItemIdGetBaseItem(itemId: itemId);

  Future<Response<UserData>> userItemsItemIdUserDataGet({
    String? itemId,
  }) async =>
      user.userItemsItemIdUserDataGet(itemId: itemId);

  Future<Response<UserData>?> userItemsItemIdUserDataPost({
    String? itemId,
    required UserData? body,
  }) async =>
      user.userItemsItemIdUserDataPost(itemId: itemId, body: body);

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
  }) =>
      library.itemsGet(
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
        parentId: parentId,
        fields: fields,
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

  Future<List<PhotoModel>> itemsGetAlbumPhotos({
    String? albumId,
  }) async =>
      library.itemsGetAlbumPhotos(albumId: albumId);

  Future<Response<List<ItemBaseModel>>> personsGet({
    String? searchTerm,
    int? limit,
    bool? isFavorite,
  }) async =>
      library.personsGet(searchTerm: searchTerm, limit: limit, isFavorite: isFavorite);

  Future<Response<List<ImageInfo>>> itemsItemIdImagesGet({
    String? itemId,
    bool? isFavorite,
  }) async =>
      admin.itemsItemIdImagesGet(itemId: itemId);

  Future<Response<MetadataEditorInfo>> itemsItemIdMetadataEditorGet({
    String? itemId,
  }) async =>
      admin.itemsItemIdMetadataEditorGet(itemId: itemId);

  Future<Response<RemoteImageResult>> itemsItemIdRemoteImagesGet({
    String? itemId,
    ImageType? type,
    bool? includeAllLanguages,
  }) async =>
      admin.itemsItemIdRemoteImagesGet(itemId: itemId, type: type, includeAllLanguages: includeAllLanguages);

  Future<Response> itemsItemIdPost({
    String? itemId,
    required BaseItemDto? body,
  }) async =>
      user.itemsItemIdPost(itemId: itemId, body: body);

  Future<Response<dynamic>?> itemIdImagesImageTypePost(
    ImageType type,
    String itemId,
    Uint8List data,
  ) async =>
      admin.itemIdImagesImageTypePost(type, itemId, data);

  Future<Response> itemsItemIdRemoteImagesDownloadPost({
    required String? itemId,
    required ImageType? type,
    String? imageUrl,
  }) async =>
      admin.itemsItemIdRemoteImagesDownloadPost(itemId: itemId, type: type, imageUrl: imageUrl);

  Future<Response> itemsItemIdImagesImageTypeDelete({
    required String? itemId,
    required ImageType? imageType,
    int? imageIndex,
  }) async =>
      admin.itemsItemIdImagesImageTypeDelete(itemId: itemId, imageType: imageType, imageIndex: imageIndex);

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
  }) async =>
      library.usersUserIdItemsResumeGet(
        startIndex: startIndex,
        limit: limit,
        searchTerm: searchTerm,
        parentId: parentId,
        fields: fields,
        mediaTypes: mediaTypes,
        enableUserData: enableUserData,
        enableTotalRecordCount: enableTotalRecordCount,
        enableImageTypes: enableImageTypes,
        excludeItemTypes: excludeItemTypes,
        includeItemTypes: includeItemTypes,
      );

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
  }) async =>
      library.usersUserIdItemsLatestGet(
        parentId: parentId,
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

  Future<Response<List<RecommendationDto>>> moviesRecommendationsGet({
    String? parentId,
    List<ItemFields>? fields,
    int? categoryLimit,
    int? itemLimit,
  }) async =>
      library.moviesRecommendationsGet(
        parentId: parentId,
        fields: fields,
        categoryLimit: categoryLimit,
        itemLimit: itemLimit,
      );

  Future<Response<BaseItemDtoQueryResult>> showsNextUpGet({
    int? startIndex,
    int? limit,
    String? parentId,
    DateTime? nextUpDateCutoff,
    List<ItemFields>? fields,
    bool? enableUserData,
    List<ImageType>? enableImageTypes,
    int? imageTypeLimit,
  }) async =>
      library.showsNextUpGet(
        startIndex: startIndex,
        limit: limit,
        parentId: parentId,
        nextUpDateCutoff: nextUpDateCutoff,
        fields: fields,
        enableUserData: enableUserData,
        enableImageTypes: enableImageTypes,
        imageTypeLimit: imageTypeLimit,
      );

  Future<Response<BaseItemDtoQueryResult>> genresGet({
    String? parentId,
    List<ItemSortBy>? sortBy,
    List<SortOrder>? sortOrder,
    List<BaseItemKind>? includeItemTypes,
  }) async =>
      library.genresGet(parentId: parentId, sortBy: sortBy, sortOrder: sortOrder);

  Future<Response> sessionsPlayingPost({required PlaybackStartInfo? body}) async => playback.sessionsPlayingPost(body: body);

  Future<Response> sessionsPlayingStoppedPost({
    required PlaybackStopInfo? body,
  }) =>
      playback.sessionsPlayingStoppedPost(body: body);

  Future<Response> sessionsPlayingProgressPost({required PlaybackProgressInfo? body}) async =>
      playback.sessionsPlayingProgressPost(body: body);

  Future<Response<PlaybackInfoResponse>> itemsItemIdPlaybackInfoPost({
    required String? itemId,
    required PlaybackInfoDto? body,
  }) async =>
      playback.itemsItemIdPlaybackInfoPost(itemId: itemId, body: body);

  //VideosItemsStreamGet
  Future<Response<String>> videoStreamGet(
    String? itemId,
    String? container,
    int? maxHeight,
    int? maxBitRate,
  ) async =>
      playback.videoStreamGet(itemId, container, maxHeight, maxBitRate);

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
  }) async =>
      library.showsSeriesIdEpisodesGet(
        seriesId: seriesId,
        fields: fields,
        season: season,
        seasonId: seasonId,
        isMissing: isMissing,
        adjacentTo: adjacentTo,
        startItemId: startItemId,
        startIndex: startIndex,
        limit: limit,
        enableImages: enableImages,
        imageTypeLimit: imageTypeLimit,
        enableImageTypes: enableImageTypes,
        enableUserData: enableUserData,
        sortBy: sortBy,
      );

  Future<List<ItemBaseModel>> fetchEpisodeFromShow({
    required String? seriesId,
    String? seasonId,
  }) async =>
      library.fetchEpisodeFromShow(seriesId: seriesId, seasonId: seasonId);

  Future<Response<List<BaseItemDto>>> itemsItemIdSpecialFeaturesGet({required String itemId}) async =>
      library.itemsItemIdSpecialFeaturesGet(itemId: itemId);

  Future<Response<BaseItemDtoQueryResult>> itemsItemIdSimilarGet({
    String? itemId,
    int? limit,
  }) async =>
      library.itemsItemIdSimilarGet(itemId: itemId, limit: limit);

  Future<Response<BaseItemDtoQueryResult>> usersUserIdItemsGet({
    String? parentId,
    List<ItemSortBy>? sortBy,
    List<SortOrder>? sortOrder,
    int? limit,
    bool? recursive,
    List<BaseItemKind>? includeItemTypes,
  }) async =>
      library.usersUserIdItemsGet(
        parentId: parentId,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        recursive: recursive,
        includeItemTypes: includeItemTypes,
      );

  Future<Response<dynamic>> playlistsPlaylistIdItemsPost({
    String? playlistId,
    List<String>? ids,
  }) async =>
      playback.playlistsPlaylistIdItemsPost(playlistId: playlistId, ids: ids);

  Future<Response<dynamic>> playlistsPost({
    String? name,
    List<String>? ids,
    required CreatePlaylistDto? body,
  }) async =>
      playback.playlistsPost(name: name, ids: ids, body: body);

  Future<Response<List<AccountModel>>> usersPublicGet(
    CredentialsModel credentials,
  ) async =>
      auth.usersPublicGet(credentials);

  Future<Response<List<AccountModel>>> getAllUsers() => auth.getAllUsers();

  Future<List<DeviceInfoDto>?> getAllDevices() async => admin.getAllDevices();

  Future<List<ParentalRating>?> getParentalRatings() async => admin.getParentalRatings();

  Future<Response<UserDto>> createNewUser(CreateUserByName user) => admin.createNewUser(user);

  Future<Response<dynamic>> setUserPolicy({required String id, required UserPolicy? policy}) => admin.setUserPolicy(id: id, policy: policy);

  Future<Response<BaseItemDtoQueryResult>> libraryMediaFolders() => library.libraryMediaFolders();

  Future<Response<AuthenticationResult>> usersAuthenticateByNamePost({
    required String userName,
    required String password,
  }) async =>
      auth.usersAuthenticateByNamePost(userName: userName, password: password);

  Future<void> deleteUser(String userId) => admin.deleteUser(userId);

  Future<Response<ServerConfiguration>> systemConfigurationGet() => system.systemConfigurationGet();
  Future<Response<PublicSystemInfo>> systemInfoPublicGet() => system.systemInfoPublicGet();
  Future<Response<SystemInfo>> systemInfoGet() => system.systemInfoGet();

  Future<void> systemConfigurationPost(ServerConfiguration serverConfig) => system.systemConfigurationPost(serverConfig);

  Future<Response<List<LocalizationOption>>> localizationOptions() => system.localizationOptions();

  Future<void> libraryRefreshPost() => system.libraryRefreshPost();

  Future<void> systemRestartPost() => system.systemRestartPost();
  Future<void> systemShutdownPost() => system.systemShutdownPost();

  Future<Response<ItemCounts>> systemInfoCounts() => system.systemInfoCounts();

  Future<Response<SystemStorageDto>> getStorage() => system.getStorage();

  Future<Response<List<TaskInfo>>> getActiveTasks() => admin.getActiveTasks();

  Future<Response<List<SessionInfoDto>>> getActiveSessions({
    int timeoutSeconds = 960,
  }) =>
      system.getActiveSessions(timeoutSeconds: timeoutSeconds);

  Future<void> stopActiveTask(String taskId) => admin.stopActiveTask(taskId);
  Future<void> startTask(String taskId) => admin.startTask(taskId);

  Future<Response<dynamic>> updateTaskTriggers(String taskId, {required List<TaskTriggerInfo> triggers}) => admin.updateTaskTriggers(taskId, triggers: triggers);

  Future<Response<UserSettings>> getCustomConfig() async => user.getCustomConfig();

  Future<Response<dynamic>> setCustomConfig(UserSettings currentSettings) async => user.setCustomConfig(currentSettings);

  Future<Response> sessionsLogoutPost() => auth.sessionsLogoutPost();

  Future<Response<String>> itemsItemIdDownloadGet({
    String? itemId,
  }) =>
      user.itemsItemIdDownloadGet(itemId: itemId);

  Future<Response> collectionsCollectionIdItemsPost({required String? collectionId, required List<String>? ids}) => liveTv.collectionsCollectionIdItemsPost(collectionId: collectionId, ids: ids);
  Future<Response> collectionsCollectionIdItemsDelete({required String? collectionId, required List<String>? ids}) => liveTv.collectionsCollectionIdItemsDelete(collectionId: collectionId, ids: ids);

  Future<Response> collectionsPost({String? name, List<String>? ids, String? parentId, bool? isLocked}) => liveTv.collectionsPost(name: name, ids: ids, parentId: parentId, isLocked: isLocked);

  Future<Response<BaseItemDtoQueryResult>> usersUserIdViewsGet({
    bool? includeExternalContent,
    List<CollectionType>? presetViews,
    bool? includeHidden,
  }) =>
      library.usersUserIdViewsGet(
        includeExternalContent: includeExternalContent,
        presetViews: presetViews,
        includeHidden: includeHidden,
      );

  Future<Response<List<ExternalIdInfo>>> itemsItemIdExternalIdInfosGet({required String? itemId}) => library.itemsItemIdExternalIdInfosGet(itemId: itemId);

  Future<Response<List<RemoteSearchResult>>> itemsRemoteSearchSeriesPost({required SeriesInfoRemoteSearchQuery? body}) => library.itemsRemoteSearchSeriesPost(body: body);

  Future<Response<List<RemoteSearchResult>>> itemsRemoteSearchMoviePost({required MovieInfoRemoteSearchQuery? body}) => library.itemsRemoteSearchMoviePost(body: body);

  Future<Response<List<CultureDto>>> localizationCulturesGet() => system.localizationCulturesGet();
  Future<Response<List<CountryInfo>>> localizationCountriesGet() => system.localizationCountriesGet();
  Future<Response<List<VirtualFolderInfo>>> libraryVirtualFoldersGet() => admin.libraryVirtualFoldersGet();

  Future<Response<LibraryOptionsResultDto>> librariesAvailableOptionsGet({
    LibrariesAvailableOptionsGetLibraryContentType? libraryContentType,
    bool? isNewLibrary,
  }) =>
      admin.librariesAvailableOptionsGet(
        libraryContentType: libraryContentType,
        isNewLibrary: isNewLibrary,
      );

  Future<Response<dynamic>> itemsRemoteSearchApplyItemIdPost({
    required String? itemId,
    bool? replaceAllImages,
    required RemoteSearchResult? body,
  }) =>
      library.itemsRemoteSearchApplyItemIdPost(
        itemId: itemId,
        replaceAllImages: replaceAllImages,
        body: body,
      );

  Future<Response<BaseItemDtoQueryResult>> showsSeriesIdSeasonsGet({
    required String? seriesId,
    bool? enableUserData,
    bool? isMissing,
    List<ItemFields>? fields,
  }) async =>
      library.showsSeriesIdSeasonsGet(
        seriesId: seriesId,
        enableUserData: enableUserData,
        isMissing: isMissing,
        fields: fields,
      );

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
      library.itemsFilters2Get(
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
      library.studiosGet(
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
        userId: userId,
        nameStartsWithOrGreater: nameStartsWithOrGreater,
        nameStartsWith: nameStartsWith,
        nameLessThan: nameLessThan,
        enableImages: enableImages,
        enableTotalRecordCount: enableTotalRecordCount,
      );

  Future<Response<ServerQueryResult>> albumInstantMixGet({
    required String itemId,
    int? limit,
  }) async =>
      playback.albumInstantMixGet(itemId: itemId, limit: limit);

  Future<Response<ServerQueryResult>> artistInstantMixGet({
    required String itemId,
    int? limit,
  }) async =>
      playback.artistInstantMixGet(itemId: itemId, limit: limit);

  Future<Response<ServerQueryResult>> audioInstantMixGet({
    required String itemId,
    int? limit,
  }) async =>
      playback.audioInstantMixGet(itemId: itemId, limit: limit);

  Future<Response<ServerQueryResult>> playlistsPlaylistIdItemsGet({
    required String? playlistId,
    int? startIndex,
    int? limit,
    List<ItemFields>? fields,
    bool? enableImages,
    bool? enableUserData,
    int? imageTypeLimit,
    List<ImageType>? enableImageTypes,
  }) async =>
      playback.playlistsPlaylistIdItemsGet(
        playlistId: playlistId,
        startIndex: startIndex,
        limit: limit,
        fields: fields,
        enableImages: enableImages,
        enableUserData: enableUserData,
        imageTypeLimit: imageTypeLimit,
        enableImageTypes: enableImageTypes,
      );

  Future<Response> playlistsPlaylistIdItemsDelete({required String? playlistId, List<String>? entryIds}) =>
      playback.playlistsPlaylistIdItemsDelete(playlistId: playlistId, entryIds: entryIds);

  Future<Response<UserDto>> usersMeGet() => user.usersMeGet();

  Future<Response> configuration() => system.configuration();

  Future<Response> itemsItemIdRefreshPost({
    required String? itemId,
    MetadataRefresh? metadataRefreshMode,
    MetadataRefresh? imageRefreshMode,
    bool? replaceAllMetadata,
    bool? replaceAllImages,
    bool? replaceTrickplayImages,
  }) =>
      user.itemsItemIdRefreshPost(
        itemId: itemId,
        metadataRefreshMode: metadataRefreshMode,
        imageRefreshMode: imageRefreshMode,
        replaceAllMetadata: replaceAllMetadata,
        replaceAllImages: replaceAllImages,
        replaceTrickplayImages: replaceTrickplayImages,
      );

  Future<Response<UserItemDataDto>> usersUserIdFavoriteItemsItemIdPost({
    required String? itemId,
  }) async =>
      user.usersUserIdFavoriteItemsItemIdPost(itemId: itemId);

  Future<Response<UserItemDataDto>> usersUserIdFavoriteItemsItemIdDelete({
    required String? itemId,
  }) async =>
      user.usersUserIdFavoriteItemsItemIdDelete(itemId: itemId);

  Future<Response<UserItemDataDto>> usersUserIdPlayedItemsItemIdPost({
    required String? itemId,
    DateTime? datePlayed,
  }) async =>
      user.usersUserIdPlayedItemsItemIdPost(itemId: itemId, datePlayed: datePlayed);

  Future<Response<UserItemDataDto>> usersUserIdPlayedItemsItemIdDelete({
    required String? itemId,
  }) async =>
      user.usersUserIdPlayedItemsItemIdDelete(itemId: itemId);

  Future<Response<MediaSegmentsModel>?> mediaSegmentsGet({
    required String id,
  }) async =>
      playback.mediaSegmentsGet(id: id);

  Future<Response<TrickPlayModel>?> getTrickPlay({
    required ItemBaseModel? item,
    int? width,
    required Ref ref,
  }) async =>
      playback.getTrickPlay(item: item, width: width, ref: ref);

  Future<Response<List<SessionInfoDto>>> sessionsInfo(String deviceId) async => playback.sessionsInfo(deviceId);

  Future<Response<bool>> quickConnect(String code) async => auth.quickConnect(code);

  Future<Response<bool>> quickConnectEnabled() async => auth.quickConnectEnabled();

  Future<Response<BrandingOptionsDto>> getBranding() async => auth.getBranding();

  Future<Response<dynamic>> deleteItem(String itemId) => admin.deleteItem(itemId);


  Future<UserConfiguration?> updateRememberAudioSelections() => user.updateRememberAudioSelections();

  Future<UserConfiguration?> updateRememberSubtitleSelections() => user.updateRememberSubtitleSelections();

  Future<UserConfiguration?> updateUserConfiguration(UserConfiguration newConfiguration) => user.updateUserConfiguration(newConfiguration);

  Future<Response<QuickConnectResult>> quickConnectInitiate() async => auth.quickConnectInitiate();

  Future<Response<QuickConnectResult>> quickConnectConnectGet({
    String? secret,
  }) async =>
      auth.quickConnectConnectGet(secret: secret);

  Future<Response<AuthenticationResult>> quickConnectAuthenticate(String secret) async =>
      auth.quickConnectAuthenticate(secret);

  Future<Response<dynamic>> resetPassword({
    required String userId,
  }) =>
      admin.resetPassword(userId: userId);

  Future<Response<dynamic>> setNewPassword({
    String? userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      admin.setNewPassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

  Future<void> userViewsViewIdDelete({required String viewId}) async => admin.userViewsViewIdDelete(viewId: viewId);

  Future<Response<DefaultDirectoryBrowserInfoDto>> defaultDirectoryGet() => admin.defaultDirectoryGet();

  Future<Response<List<FileSystemEntryInfo>>> getDriveLocations() => admin.getDriveLocations();

  Future<Response<List<FileSystemEntryInfo>>> directoryContentsGet({
    required String? path,
    bool? includeFiles,
    bool? includeDirectories,
  }) =>
      admin.directoryContentsGet(path: path, includeFiles: includeFiles, includeDirectories: includeDirectories);

  Future<Response<String>> parentPathGet(
    String path,
  ) async =>
      admin.parentPathGet(path);

  Future<Response<dynamic>> virtualFoldersUpdate({
    required String id,
    required LibraryOptions? libraryOptions,
  }) =>
      admin.virtualFoldersUpdate(id: id, libraryOptions: libraryOptions);

  Future<Response<dynamic>> virtualFoldersPost({
    required VirtualFolderInfo newFolder,
    bool? refreshLibrary,
  }) =>
      admin.virtualFoldersPost(newFolder: newFolder, refreshLibrary: refreshLibrary);

  Future<Response<BaseItemDtoQueryResult>> liveTvChannelsGet({
    int? limit,
  }) async =>
      liveTv.liveTvChannelsGet(limit: limit);

  Future<Response<BaseItemDtoQueryResult>> liveTvChannelPrograms({
    required List<String> channelIds,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    DateTime? minEndDate,
    DateTime? maxEndDate,
  }) async =>
      liveTv.liveTvChannelPrograms(
        channelIds: channelIds,
        minStartDate: minStartDate,
        maxStartDate: maxStartDate,
        minEndDate: minEndDate,
        maxEndDate: maxEndDate,
      );

  Future<Response<LiveTvOptions>> getLiveTvConfiguration() async => liveTv.getLiveTvConfiguration();

  Future<Response> updateLiveTvConfiguration(LiveTvOptions liveTvOptions) async =>
      liveTv.updateLiveTvConfiguration(liveTvOptions);

  // Tuner Hosts
  Future<Response<TunerHostInfo>> addTunerHost(TunerHostInfo tunerHost) async =>
      liveTv.addTunerHost(tunerHost);

  Future<Response> deleteTunerHost(String id) async => liveTv.deleteTunerHost(id);

  Future<Response<List<TunerHostInfo>>> discoverTuners({bool? newDevicesOnly}) async =>
      liveTv.discoverTuners(newDevicesOnly: newDevicesOnly);

  // Listing Providers
  Future<Response<ListingsProviderInfo>> addListingProvider(
    ListingsProviderInfo provider, {
    String? pw,
    bool? validateListings,
    bool? validateLogin,
  }) async =>
      liveTv.addListingProvider(
        provider,
        pw: pw,
        validateListings: validateListings,
        validateLogin: validateLogin,
      );

  Future<Response> deleteListingProvider(String id) async => liveTv.deleteListingProvider(id);

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
  }) =>
      playback.buildVideoStreamUrl(
        itemId: itemId,
        container: container,
        $static: $static,
        params: params,
        tag: tag,
        deviceProfileId: deviceProfileId,
        playSessionId: playSessionId,
        segmentContainer: segmentContainer,
        segmentLength: segmentLength,
        minSegments: minSegments,
        mediaSourceId: mediaSourceId,
        deviceId: deviceId,
        audioCodec: audioCodec,
        enableAutoStreamCopy: enableAutoStreamCopy,
        allowVideoStreamCopy: allowVideoStreamCopy,
        allowAudioStreamCopy: allowAudioStreamCopy,
        breakOnNonKeyFrames: breakOnNonKeyFrames,
        audioSampleRate: audioSampleRate,
        maxAudioBitDepth: maxAudioBitDepth,
        audioBitRate: audioBitRate,
        audioChannels: audioChannels,
        maxAudioChannels: maxAudioChannels,
        profile: profile,
        level: level,
        framerate: framerate,
        maxFramerate: maxFramerate,
        copyTimestamps: copyTimestamps,
        startTimeTicks: startTimeTicks,
        width: width,
        height: height,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        videoBitRate: videoBitRate,
        subtitleStreamIndex: subtitleStreamIndex,
        subtitleMethod: subtitleMethod,
        maxRefFrames: maxRefFrames,
        maxVideoBitDepth: maxVideoBitDepth,
        requireAvc: requireAvc,
        deInterlace: deInterlace,
        requireNonAnamorphic: requireNonAnamorphic,
        transcodingMaxAudioChannels: transcodingMaxAudioChannels,
        cpuCoreLimit: cpuCoreLimit,
        liveStreamId: liveStreamId,
        enableMpegtsM2TsMode: enableMpegtsM2TsMode,
        videoCodec: videoCodec,
        subtitleCodec: subtitleCodec,
        transcodeReasons: transcodeReasons,
        audioStreamIndex: audioStreamIndex,
        videoStreamIndex: videoStreamIndex,
        context: context,
        streamOptions: streamOptions,
        enableAudioVbrEncoding: enableAudioVbrEncoding,
      );
}
