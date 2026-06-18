import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/providers/connectivity_provider.dart';
import 'package:fladder/providers/sync_provider.dart';
import 'package:fladder/jellyfin/enum_models.dart';
import 'package:fladder/models/account_model.dart';
import 'package:fladder/util/map_parsing.dart';
import 'package:fladder/providers/user_provider.dart';

class UserService {
  final JellyfinOpenApi _api;
  final Ref ref;

  Future<Response<UserDto>> usersMeGet() async {
    return _api.usersMeGet();
  }

  UserService(this._api, this.ref);

  Future<Response<ItemBaseModel>> _syncedItemResponse(String? itemId) async {
    final item = (await ref.read(syncProvider.notifier).getSyncedItem(itemId))?.itemModel;
    return Response<ItemBaseModel>(
      http.Response("", 202),
      item,
    );
  }

  Future<Response<ItemBaseModel>> usersUserIdItemsItemIdGet({
    String? itemId,
  }) async {
    final isOffline = ref.read(connectivityStatusProvider.notifier).getConnectivityStates() == ConnectionState.offline;
    if (isOffline) {
      return _syncedItemResponse(itemId);
    }

    try {
      final response = await _api.itemsItemIdGet(
        userId: ref.read(userProvider)?.id,
        itemId: itemId,
      );
      return response.copyWith(body: ItemBaseModel.fromBaseDto(response.bodyOrThrow, ref));
    } catch (e) {
      return _syncedItemResponse(itemId);
    }
  }

  Future<Response<BaseItemDto>> usersUserIdItemsItemIdGetBaseItem({
    String? itemId,
  }) async {
    final isOffline = ref.read(connectivityStatusProvider.notifier).getConnectivityStates() == ConnectionState.offline;
    if (isOffline) {
      final syncedItem = await ref.read(syncProvider.notifier).getSyncedItem(itemId);
      return syncedItem?.data != null
          ? Response<BaseItemDto>(
              http.Response("", 202),
              syncedItem?.data,
            )
          : Response<BaseItemDto>(
              http.Response("", 404),
              null,
            );
    }

    try {
      return await _api.itemsItemIdGet(
        userId: ref.read(userProvider)?.id,
        itemId: itemId,
      );
    } catch (e) {
      final syncedItem = await ref.read(syncProvider.notifier).getSyncedItem(itemId);
      return syncedItem?.data != null
          ? Response<BaseItemDto>(
              http.Response("", 202),
              syncedItem?.data,
            )
          : Response<BaseItemDto>(
              http.Response("", 404),
              null,
            );
    }
  }

  Future<Response<UserData>> userItemsItemIdUserDataGet({
    String? itemId,
  }) async {
    final response = await _api.userItemsItemIdUserDataGet(
      userId: ref.read(userProvider)?.id,
      itemId: itemId,
    );
    return response.copyWith(
      body: UserData.fromDto(response.bodyOrThrow),
    );
  }

  Future<Response<UserData>?> userItemsItemIdUserDataPost({
    String? itemId,
    required UserData? body,
  }) async {
    if (body == null) {
      return null;
    }
    final response = await _api.userItemsItemIdUserDataPost(
      userId: ref.read(userProvider)?.id,
      itemId: itemId,
      body: UpdateUserItemDataDto(
        playCount: body.playCount,
        playbackPositionTicks: body.playbackPositionTicks,
        isFavorite: body.isFavourite,
        played: body.played,
        lastPlayedDate: body.lastPlayed,
        itemId: itemId,
      ),
    );
    return response.copyWith(
      body: UserData.fromDto(response.bodyOrThrow),
    );
  }

  Future<Response<UserItemDataDto>> usersUserIdFavoriteItemsItemIdPost({
    required String? itemId,
  }) async {
    Response<UserItemDataDto>? response;
    try {
      response = await _api.userFavoriteItemsItemIdPost(
        itemId: itemId,
        userId: ref.read(userProvider)?.id,
      );
    } finally {
      await ref
          .read(syncProvider.notifier)
          .updateFavoriteItem(itemId, isFavorite: true, responseSuccessful: response?.isSuccessful ?? false);
    }
    return response;
  }

  Future<Response<UserItemDataDto>> usersUserIdFavoriteItemsItemIdDelete({
    required String? itemId,
  }) async {
    Response<UserItemDataDto>? response;
    try {
      response = await _api.userFavoriteItemsItemIdDelete(
        itemId: itemId,
        userId: ref.read(userProvider)?.id,
      );
    } finally {
      await ref
          .read(syncProvider.notifier)
          .updateFavoriteItem(itemId, isFavorite: false, responseSuccessful: response?.isSuccessful ?? false);
    }
    return response;
  }

  Future<Response<UserItemDataDto>> usersUserIdPlayedItemsItemIdPost({
    required String? itemId,
    DateTime? datePlayed,
  }) async {
    Response<UserItemDataDto>? response;
    try {
      response = await _api.userPlayedItemsItemIdPost(itemId: itemId, userId: ref.read(userProvider)?.id, datePlayed: datePlayed);
    } finally {
      await ref.read(syncProvider.notifier).updatePlayedItem(
            itemId,
            datePlayed: datePlayed,
            played: true,
            responseSuccessful: response?.isSuccessful ?? false,
          );
    }
    return response;
  }

  Future<Response<UserItemDataDto>> usersUserIdPlayedItemsItemIdDelete({
    required String? itemId,
  }) async {
    Response<UserItemDataDto>? response;
    try {
      response = await _api.userPlayedItemsItemIdDelete(
        itemId: itemId,
        userId: ref.read(userProvider)?.id,
      );
    } finally {
      await ref.read(syncProvider.notifier).updatePlayedItem(
            itemId,
            played: false,
            responseSuccessful: response?.isSuccessful ?? false,
          );
    }

    return response;
  }

  Future<Response<String>> itemsItemIdDownloadGet({
    String? itemId,
  }) =>
      _api.itemsItemIdDownloadGet(itemId: itemId);

  Future<Response> itemsItemIdPost({
    String? itemId,
    required BaseItemDto? body,
  }) async {
    return _api.itemsItemIdPost(
      itemId: itemId,
      body: body,
    );
  }

  Future<Response> itemsItemIdRefreshPost({
    required String? itemId,
    MetadataRefresh? metadataRefreshMode,
    MetadataRefresh? imageRefreshMode,
    bool? replaceAllMetadata,
    bool? replaceAllImages,
    bool? replaceTrickplayImages,
  }) =>
      _api.itemsItemIdRefreshPost(
        itemId: itemId,
        metadataRefreshMode: metadataRefreshMode?.metadataRefreshMode,
        imageRefreshMode: imageRefreshMode?.imageRefreshMode,
        replaceAllMetadata: replaceAllMetadata,
        replaceAllImages: replaceAllImages,
        regenerateTrickplay: replaceTrickplayImages,
      );

  Future<Response<UserSettings>> getCustomConfig() async {
    final response = await _api.displayPreferencesDisplayPreferencesIdGet(
      displayPreferencesId: 'usersettings',
      userId: ref.read(userProvider)?.id ?? "",
      $client: 'fladder',
    );
    final customPrefs = response.body?.customPrefs?.parseValues();
    final userPrefs = customPrefs != null ? UserSettings.fromJson(customPrefs) : UserSettings();
    return response.copyWith(
      body: userPrefs,
    );
  }

  Future<Response<dynamic>> setCustomConfig(UserSettings currentSettings) async {
    final currentDisplayPreferences = await _api.displayPreferencesDisplayPreferencesIdGet(
      displayPreferencesId: 'usersettings',
      $client: 'fladder',
    );
    return _api.displayPreferencesDisplayPreferencesIdPost(
      displayPreferencesId: 'usersettings',
      userId: ref.read(userProvider)?.id ?? "",
      $client: 'fladder',
      body: currentDisplayPreferences.body?.copyWith(
        customPrefs: currentSettings.toJson(),
      ),
    );
  }

  Future<UserConfiguration?> _updateUserConfiguration(UserConfiguration newUserConfiguration) async {
    if (ref.read(userProvider)?.id == null) return null;

    final response = await _api.usersConfigurationPost(
      userId: ref.read(userProvider)!.id,
      body: newUserConfiguration,
    );

    if (response.isSuccessful) {
      return newUserConfiguration;
    }
    return null;
  }

  Future<UserConfiguration?> updateRememberAudioSelections() {
    final currentUserConfiguration = ref.read(userProvider)?.userConfiguration;
    if (currentUserConfiguration == null) return Future.value(null);

    final updated = currentUserConfiguration.copyWith(
      rememberAudioSelections: !(currentUserConfiguration.rememberAudioSelections ?? false),
    );
    return _updateUserConfiguration(updated);
  }

  Future<UserConfiguration?> updateRememberSubtitleSelections() {
    final current = ref.read(userProvider)?.userConfiguration;
    if (current == null) return Future.value(null);

    final updated = current.copyWith(
      rememberSubtitleSelections: !(current.rememberSubtitleSelections ?? false),
    );
    return _updateUserConfiguration(updated);
  }

  Future<UserConfiguration?> updateUserConfiguration(UserConfiguration newConfiguration) {
    return _updateUserConfiguration(newConfiguration);
  }
}
