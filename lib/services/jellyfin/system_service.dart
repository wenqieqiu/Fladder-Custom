import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';

class SystemService {
  final JellyfinOpenApi _api;
  final Ref ref;

  SystemService(this._api, this.ref);

  Future<Response<ServerConfiguration>> systemConfigurationGet() => _api.systemConfigurationGet();
  Future<Response<PublicSystemInfo>> systemInfoPublicGet() => _api.systemInfoPublicGet();
  Future<Response<SystemInfo>> systemInfoGet() => _api.systemInfoGet();

  Future<void> systemConfigurationPost(ServerConfiguration serverConfig) =>
      _api.systemConfigurationPost(body: serverConfig);

  Future<Response<List<LocalizationOption>>> localizationOptions() => _api.localizationOptionsGet();

  Future<void> libraryRefreshPost() => _api.libraryRefreshPost();

  Future<void> systemRestartPost() => _api.systemRestartPost();
  Future<void> systemShutdownPost() => _api.systemShutdownPost();

  Future<Response<ItemCounts>> systemInfoCounts() => _api.itemsCountsGet();

  Future<Response<SystemStorageDto>> getStorage() => _api.systemInfoStorageGet();

  Future<Response<List<CultureDto>>> localizationCulturesGet() => _api.localizationCulturesGet();
  Future<Response<List<CountryInfo>>> localizationCountriesGet() => _api.localizationCountriesGet();

  Future<Response> configuration() => _api.systemConfigurationGet();

  Future<Response<List<SessionInfoDto>>> getActiveSessions({
    int timeoutSeconds = 960,
  }) =>
      _api.sessionsGet(
        activeWithinSeconds: timeoutSeconds,
      );
}
