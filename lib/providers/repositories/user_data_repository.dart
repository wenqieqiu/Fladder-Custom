import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chopper/chopper.dart';
import 'package:fladder/providers/api_provider.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/providers/service_provider.dart';

/// Narrow interface for user data operations (play status, favourites).
///
/// Wraps [JellyService] methods that deal with user-specific item data.
final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  return UserDataRepository(ref.read(jellyApiProvider));
});

class UserDataRepository {
  final JellyService _api;
  UserDataRepository(this._api);

  Future<Response<UserData>> get(String itemId) =>
      _api.userItemsItemIdUserDataGet(itemId: itemId);

  Future<Response<UserData>?> post(String itemId, UserData data) =>
      _api.userItemsItemIdUserDataPost(itemId: itemId, body: data);

  Future<void> markFavorite(String itemId) =>
      _api.usersUserIdFavoriteItemsItemIdPost(itemId: itemId);

  Future<void> unmarkFavorite(String itemId) =>
      _api.usersUserIdFavoriteItemsItemIdDelete(itemId: itemId);

  Future<void> markPlayed(String itemId, {DateTime? datePlayed}) =>
      _api.usersUserIdPlayedItemsItemIdPost(itemId: itemId, datePlayed: datePlayed);

  Future<void> markUnplayed(String itemId) =>
      _api.usersUserIdPlayedItemsItemIdDelete(itemId: itemId);
}
