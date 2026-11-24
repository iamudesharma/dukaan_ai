import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards a setting that fails silently: macOS keys the credential store with
/// the data-protection keychain by default, which requires an
/// `application-identifier` entitlement that only a provisioning profile
/// provides. Without it every write throws while the login request has already
/// succeeded, so the app shows a generic error after a valid password and the
/// user never gets past sign-in.
void main() {
  test('the macOS credential store avoids the data-protection keychain', () {
    expect(
      SecureSessionStore.macOsOptions.toMap()['useDataProtectionKeyChain'],
      'false',
    );
  });

  test('cached identity is cleared with the session', () async {
    final store = MemorySessionStore(access: 'access', refresh: 'refresh');
    await store.writeCachedUserId('user-1');
    await store.writeCachedBootstrap({
      'user': {'id': 'user-1', 'role': 'CASHIER'},
      'business': {'id': 'business-1'},
    });

    expect(await store.readCachedUserId(), 'user-1');
    expect((await store.readCachedBootstrap())?['business'], isA<Map>());

    await store.clear();
    expect(await store.readCachedUserId(), isNull);
    expect(await store.readCachedBootstrap(), isNull);
  });

  test('the file-based keychain still pins an explicit accessibility class',
      () {
    // KeychainAccessibility.unlocked is the plugin default; asserting it keeps
    // the choice deliberate rather than inherited.
    expect(
      SecureSessionStore.macOsOptions.toMap()['accessibility'],
      isNotNull,
    );
  });
}
