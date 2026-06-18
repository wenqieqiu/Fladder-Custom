import 'package:flutter/foundation.dart';
import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart' as enums;
import 'package:fladder/util/jellyfin_extension.dart';
import 'package:fladder/providers/user_provider.dart';

class AdminService {
  final JellyfinOpenApi _api;
  final Ref ref;

  AdminService(this._api, this.ref);

  Future<List<DeviceInfoDto>?> getAllDevices() async {
    return (await _api.devicesGet(
      userId: ref.read(userProvider)?.id,
    ))
        .body
        ?.items;
  }

  Future<List<ParentalRating>?> getParentalRatings() async {
    return (await _api.localizationParentalRatingsGet()).body;
  }

  Future<Response<UserDto>> createNewUser(CreateUserByName user) => _api.usersNewPost(body: user);

  Future<Response<dynamic>> setUserPolicy({required String id, required UserPolicy? policy}) =>
      _api.usersUserIdPolicyPost(
        userId: id,
        body: policy,
      );

  Future<void> deleteUser(String userId) => _api.usersUserIdDelete(userId: userId);
  Future<Response<dynamic>> resetPassword({
    required String userId,
  }) {
    return _api.usersPasswordPost(
      userId: userId,
      body: const UpdateUserPassword(
        resetPassword: true,
      ),
    );
  }

  Future<Response<dynamic>> setNewPassword({
    String? userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _api.usersPasswordPost(
      userId: userId,
      body: UpdateUserPassword(
        currentPassword: currentPassword,
        newPw: newPassword,
        currentPw: confirmPassword,
      ),
    );
  }

  Future<Response<List<TaskInfo>>> getActiveTasks() => _api.scheduledTasksGet();

  Future<void> stopActiveTask(String taskId) => _api.scheduledTasksRunningTaskIdDelete(taskId: taskId);
  Future<void> startTask(String taskId) => _api.scheduledTasksRunningTaskIdPost(taskId: taskId);

  Future<Response<dynamic>> updateTaskTriggers(String taskId, {required List<TaskTriggerInfo> triggers}) =>
      _api.scheduledTasksTaskIdTriggersPost(
        taskId: taskId,
        body: triggers,
      );

  Future<Response<List<VirtualFolderInfo>>> libraryVirtualFoldersGet() => _api.libraryVirtualFoldersGet();

  Future<Response<LibraryOptionsResultDto>> librariesAvailableOptionsGet({
    LibrariesAvailableOptionsGetLibraryContentType? libraryContentType,
    bool? isNewLibrary,
  }) =>
      _api.librariesAvailableOptionsGet(
        libraryContentType: libraryContentType,
        isNewLibrary: isNewLibrary,
      );

  Future<Response<dynamic>> virtualFoldersUpdate({
    required String id,
    required LibraryOptions? libraryOptions,
  }) {
    return _api.libraryVirtualFoldersLibraryOptionsPost(
      body: UpdateLibraryOptionsDto(
        id: id,
        libraryOptions: libraryOptions,
      ),
    );
  }

  Future<Response<dynamic>> virtualFoldersPost({
    required VirtualFolderInfo newFolder,
    bool? refreshLibrary,
  }) {
    return _api.libraryVirtualFoldersPost(
      name: newFolder.name ?? "",
      collectionType: switch (newFolder.collectionType) {
        CollectionTypeOptions.movies => LibraryVirtualFoldersPostCollectionType.movies,
        CollectionTypeOptions.tvshows => LibraryVirtualFoldersPostCollectionType.tvshows,
        CollectionTypeOptions.music => LibraryVirtualFoldersPostCollectionType.music,
        CollectionTypeOptions.books => LibraryVirtualFoldersPostCollectionType.books,
        CollectionTypeOptions.homevideos => LibraryVirtualFoldersPostCollectionType.homevideos,
        _ => LibraryVirtualFoldersPostCollectionType.mixed,
      },
      paths: newFolder.locations,
      refreshLibrary: refreshLibrary,
      body: AddVirtualFolderDto(
        libraryOptions: newFolder.libraryOptions,
      ),
    );
  }

  Future<Response<DefaultDirectoryBrowserInfoDto>> defaultDirectoryGet() =>
      _api.environmentDefaultDirectoryBrowserGet();

  Future<Response<List<FileSystemEntryInfo>>> getDriveLocations() => _api.environmentDrivesGet();

  Future<Response<List<FileSystemEntryInfo>>> directoryContentsGet({
    required String? path,
    bool? includeFiles,
    bool? includeDirectories,
  }) {
    return _api.environmentDirectoryContentsGet(
      path: path,
      includeFiles: includeFiles,
      includeDirectories: includeDirectories,
    );
  }

  Future<Response<String>> parentPathGet(
    String path,
  ) async {
    return _api.environmentParentPathGet(
      path: path,
    );
  }

  Future<void> userViewsViewIdDelete({required String viewId}) async {
    if (kDebugMode) {
      log("Deleting view with ID: $viewId");
      return;
    }
  }

  Future<Response<List<ImageInfo>>> itemsItemIdImagesGet({
    String? itemId,
    bool? isFavorite,
  }) async {
    final response = await _api.itemsItemIdImagesGet(itemId: itemId);
    return response;
  }

  Future<Response<MetadataEditorInfo>> itemsItemIdMetadataEditorGet({
    String? itemId,
  }) async {
    return _api.itemsItemIdMetadataEditorGet(itemId: itemId);
  }

  Future<Response<RemoteImageResult>> itemsItemIdRemoteImagesGet({
    String? itemId,
    ImageType? type,
    bool? includeAllLanguages,
  }) async {
    return _api.itemsItemIdRemoteImagesGet(
      itemId: itemId,
      type: enums.ItemsItemIdRemoteImagesGetType.values.firstWhereOrNull(
        (element) => element.value == type?.value,
      ),
      includeAllLanguages: includeAllLanguages,
    );
  }

  Future<Response<dynamic>?> itemIdImagesImageTypePost(
    ImageType type,
    String itemId,
    Uint8List data,
  ) async {
    return _api.itemIdImagesImageTypePost(
      type,
      itemId,
      data,
    );
  }

  Future<Response> itemsItemIdRemoteImagesDownloadPost({
    required String? itemId,
    required ImageType? type,
    String? imageUrl,
  }) async {
    return _api.itemsItemIdRemoteImagesDownloadPost(
      itemId: itemId,
      type: enums.ItemsItemIdRemoteImagesDownloadPostType.values.firstWhereOrNull(
        (element) => element.value == type?.value,
      ),
      imageUrl: imageUrl,
    );
  }

  Future<Response> itemsItemIdImagesImageTypeDelete({
    required String? itemId,
    required ImageType? imageType,
    int? imageIndex,
  }) async {
    return _api.itemsItemIdImagesImageTypeDelete(
      itemId: itemId,
      imageType: enums.ItemsItemIdImagesImageTypeDeleteImageType.values.firstWhereOrNull(
        (element) => element.value == imageType?.value,
      ),
      imageIndex: imageIndex,
    );
  }

  Future<Response<dynamic>> deleteItem(String itemId) => _api.itemsItemIdDelete(itemId: itemId);
}
