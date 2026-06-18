import 'dart:convert';
import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/providers/user_provider.dart';

class LiveTvService {
  final JellyfinOpenApi _api;
  final Ref ref;

  LiveTvService(this._api, this.ref);

  Future<Response<BaseItemDtoQueryResult>> liveTvChannelsGet({
    int? limit,
  }) async {
    return await _api.liveTvChannelsGet(
      limit: limit,
      userId: ref.read(userProvider)?.id,
      addCurrentProgram: true,
    );
  }

  Future<Response<BaseItemDtoQueryResult>> liveTvChannelPrograms({
    required List<String> channelIds,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    DateTime? minEndDate,
    DateTime? maxEndDate,
  }) async {
    return await _api.liveTvProgramsGet(
      channelIds: channelIds,
      userId: ref.read(userProvider)?.id,
      minStartDate: minStartDate,
      maxStartDate: maxStartDate,
      minEndDate: minEndDate,
      maxEndDate: maxEndDate,
      enableUserData: false,
      sortBy: [ItemSortBy.startdate],
      fields: [
        ItemFields.overview,
        ItemFields.parentid,
      ],
      enableTotalRecordCount: false,
    );
  }

  Future<Response<LiveTvOptions>> getLiveTvConfiguration() async {
    final response = await _api.systemConfigurationKeyGet(key: 'livetv');
    if (response.body == null) {
      return Response(response.base, null);
    }
    try {
      final jsonData = jsonDecode(response.body!) as Map<String, dynamic>;
      final liveTvOptions = LiveTvOptions.fromJsonFactory(jsonData);
      return Response(response.base, liveTvOptions);
    } catch (e) {
      log('Failed to parse LiveTvOptions: $e');
      return Response(response.base, null);
    }
  }

  Future<Response> updateLiveTvConfiguration(LiveTvOptions liveTvOptions) async {
    return _api.systemConfigurationKeyPost(key: 'livetv', body: liveTvOptions);
  }

  // Tuner Hosts
  Future<Response<TunerHostInfo>> addTunerHost(TunerHostInfo tunerHost) async {
    return _api.liveTvTunerHostsPost(body: tunerHost);
  }

  Future<Response> deleteTunerHost(String id) async {
    return _api.liveTvTunerHostsDelete(id: id);
  }

  Future<Response<List<TunerHostInfo>>> discoverTuners({bool? newDevicesOnly}) async {
    return _api.liveTvTunersDiscoverGet(newDevicesOnly: newDevicesOnly);
  }

  // Listing Providers
  Future<Response<ListingsProviderInfo>> addListingProvider(
    ListingsProviderInfo provider, {
    String? pw,
    bool? validateListings,
    bool? validateLogin,
  }) async {
    return _api.liveTvListingProvidersPost(
      body: provider,
      pw: pw,
      validateListings: validateListings,
      validateLogin: validateLogin,
    );
  }

  Future<Response> deleteListingProvider(String id) async {
    return _api.liveTvListingProvidersDelete(id: id);
  }

  Future<Response> collectionsCollectionIdItemsPost({required String? collectionId, required List<String>? ids}) =>
      _api.collectionsCollectionIdItemsPost(collectionId: collectionId, ids: ids);

  Future<Response> collectionsCollectionIdItemsDelete({required String? collectionId, required List<String>? ids}) =>
      _api.collectionsCollectionIdItemsDelete(collectionId: collectionId, ids: ids);

  Future<Response> collectionsPost({String? name, List<String>? ids, String? parentId, bool? isLocked}) =>
      _api.collectionsPost(name: name, ids: ids, parentId: parentId, isLocked: isLocked);
}
