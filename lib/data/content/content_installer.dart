import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

/// Thrown when the bundled content database is missing or damaged.
class ContentInstallException implements Exception {
  ContentInstallException(this.message);

  final String message;

  @override
  String toString() => 'ContentInstallException: $message';
}

/// Copies the bundled canonical database out of the app assets (SQLite
/// cannot open an asset directly) and verifies it byte for byte against the
/// SHA-256 recorded by the importer. The copy is refreshed only when a new
/// app version ships different content.
class ContentInstaller {
  ContentInstaller({required this.bundle, required this.directory});

  static const String dbAsset = 'assets/content/bukhari_taseel.db';
  static const String versionAsset = 'assets/content/content_version.json';

  final AssetBundle bundle;
  final Directory directory;

  File get _dbFile => File('${directory.path}/bukhari_taseel.db');
  File get _markerFile => File('${directory.path}/installed_content.json');

  Future<File> ensureInstalled() async {
    final version = jsonDecode(await bundle.loadString(versionAsset)) as Map<String, dynamic>;
    final expected = version['sha256'] as String;
    if (await _dbFile.exists() && await _markerFile.exists()) {
      final marker = jsonDecode(await _markerFile.readAsString()) as Map<String, dynamic>;
      if (marker['sha256'] == expected) return _dbFile;
    }
    await directory.create(recursive: true);
    final data = await bundle.load(dbAsset);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final actual = sha256.convert(bytes).toString();
    if (actual != expected) {
      throw ContentInstallException('bundled content checksum mismatch (expected $expected, found $actual)');
    }
    final tmp = File('${_dbFile.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(_dbFile.path);
    await _markerFile.writeAsString(jsonEncode(version), flush: true);
    return _dbFile;
  }
}
