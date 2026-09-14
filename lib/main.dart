import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/theme.dart';
import 'data/content/content_database.dart';
import 'data/content/content_installer.dart';
import 'data/content/content_repository.dart';
import 'data/user/user_database.dart';
import 'data/user/user_repository.dart';
import 'features/settings/app_settings.dart';
import 'l10n/gen/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final (name, path) in const [
      ('Amiri font', 'assets/fonts/amiri/OFL.txt'),
      ('Noto Naskh Arabic font', 'assets/fonts/noto_naskh_arabic/OFL.txt'),
      ('Noto Sans Arabic font', 'assets/fonts/noto_sans_arabic/OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString(path));
    }
  });
  runApp(const Bootstrap());
}

class _Deps {
  const _Deps(this.content, this.user, this.settings, this.version);

  final ContentDatabase content;
  final UserDatabase user;
  final AppSettings settings;
  final String version;
}

/// Installs/verifies the bundled content, opens the databases and loads the
/// settings, then starts the app. Everything is local; no network access.
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<_Deps> _deps = _init();

  Future<_Deps> _init() async {
    final support = await getApplicationSupportDirectory();
    final dbFile = await ContentInstaller(
      bundle: rootBundle,
      directory: Directory('${support.path}/content'),
    ).ensureInstalled();
    final content = ContentDatabase.open(dbFile);
    final schema = await ContentRepository(content).schemaVersion();
    if (schema != ContentDatabase.supportedSchemaVersion) {
      throw ContentInstallException('unsupported content schema $schema');
    }
    final user = UserDatabase.open(File('${support.path}/user_data.sqlite'));
    final settings = AppSettings.fromMap(await UserRepository(user).settings());
    final info = await PackageInfo.fromPlatform();
    return _Deps(content, user, settings, '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Deps>(
    future: _deps,
    builder: (context, snapshot) {
      final deps = snapshot.data;
      if (deps != null) {
        return ProviderScope(
          overrides: [
            contentDatabaseProvider.overrideWithValue(deps.content),
            userDatabaseProvider.overrideWithValue(deps.user),
            initialSettingsProvider.overrideWithValue(deps.settings),
            appVersionProvider.overrideWithValue(deps.version),
          ],
          child: const SahihApp(),
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: snapshot.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context).contentInstallError, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => setState(() => _deps = _init()),
                            child: Text(AppLocalizations.of(context).retry),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    },
  );
}
