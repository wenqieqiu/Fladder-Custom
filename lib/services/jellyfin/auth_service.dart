import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/account_model.dart';
import 'package:fladder/models/credentials_model.dart';
import 'package:fladder/providers/image_provider.dart';

class AuthService {
  final JellyfinOpenApi _api;
  final Ref ref;

  AuthService(this._api, this.ref);

  Future<Response<List<AccountModel>>> usersPublicGet(
    CredentialsModel credentials,
  ) async {
    final response = await _api.usersPublicGet();
    return response.copyWith(
      body: response.body?.map(
        (e) {
          var imageUrl = ref.read(imageUtilityProvider).getUserImageUrl(e.id ?? "");
          return AccountModel(
            name: e.name ?? "",
            credentials: credentials,
            id: e.id ?? "",
            avatar: imageUrl,
            lastUsed: DateTime.now(),
          );
        },
      ).toList(),
    );
  }

  Future<Response<List<AccountModel>>> getAllUsers() {
    return _api.usersGet().then(
          (response) => response.copyWith(
            body: response.body?.map(
              (e) {
                var imageUrl = ref.read(imageUtilityProvider).getUserImageUrl(e.id ?? "");
                return AccountModel(
                  name: e.name ?? "",
                  credentials: CredentialsModel.createNewCredentials(),
                  id: e.id ?? "",
                  avatar: imageUrl,
                  policy: e.policy,
                  lastUsed: e.lastActivityDate ?? DateTime.now(),
                  hasPassword: e.hasPassword ?? false,
                  hasConfiguredPassword: e.hasConfiguredPassword ?? false,
                );
              },
            ).toList(),
          ),
        );
  }

  Future<Response<AuthenticationResult>> usersAuthenticateByNamePost({
    required String userName,
    required String password,
  }) async {
    return _api.usersAuthenticateByNamePost(body: AuthenticateUserByName(username: userName, pw: password));
  }

  Future<Response> sessionsLogoutPost() => _api.sessionsLogoutPost();

  Future<Response<bool>> quickConnect(String code) async => _api.quickConnectAuthorizePost(code: code);

  Future<Response<bool>> quickConnectEnabled() async => _api.quickConnectEnabledGet();

  Future<Response<BrandingOptionsDto>> getBranding() async => _api.brandingConfigurationGet();

  Future<Response<QuickConnectResult>> quickConnectInitiate() async {
    return _api.quickConnectInitiatePost();
  }

  Future<Response<QuickConnectResult>> quickConnectConnectGet({
    String? secret,
  }) async {
    return _api.quickConnectConnectGet(secret: secret);
  }

  Future<Response<AuthenticationResult>> quickConnectAuthenticate(String secret) async {
    return _api.usersAuthenticateWithQuickConnectPost(
      body: QuickConnectDto(secret: secret),
    );
  }
}
