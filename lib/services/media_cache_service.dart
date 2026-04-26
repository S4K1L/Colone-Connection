import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MediaCacheService {
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  final Map<String, Future<File>> _downloadFutures = {};

  /// Stable, low-collision cache name (avoid `String.hashCode` collisions across many URLs).
  static String cacheFileStem(String url) =>
      sha256.convert(utf8.encode(url)).toString();

  Future<File?> getCachedFile(String url) async {
    if (url.isEmpty) return null;

    try {
      final cacheDir = await _getCacheDirectory();
      final extension = _getFileExtension(url);
      final fileName = "${cacheFileStem(url)}.$extension";
      final filePath = "${cacheDir.path}/$fileName";
      final file = File(filePath);

      if (await file.exists()) {
        // Check if file is older than 24 hours
        final lastModified = await file.lastModified();
        final now = DateTime.now();
        if (now.difference(lastModified).inHours > 24) {
          debugPrint("⏳ File older than 24h, will re-download if needed: $url");
          // Optionally delete or just let it be overwritten by new download
        } else {
          debugPrint("✅ Returning cached file: $filePath");
          return file;
        }
      }

      // If not exists or needs refresh, download it
      return await downloadAndCache(url);
    } catch (e) {
      debugPrint("❌ Error in getCachedFile: $e");
      return null;
    }
  }

  Future<File?> downloadAndCache(String url) async {
    if (url.isEmpty) return null;

    // Prevent duplicate downloads for the same URL
    if (_downloadFutures.containsKey(url)) {
      return _downloadFutures[url];
    }

    final downloadFuture = _download(url);
    _downloadFutures[url] = downloadFuture;

    try {
      final file = await downloadFuture;
      return file;
    } catch (e) {
      debugPrint("❌ Download failed for $url: $e");
      return null;
    } finally {
      _downloadFutures.remove(url);
    }
  }

  Future<File?> downloadAndCacheWithProgress(
    String url, {
    ValueChanged<double>? onProgress,
  }) async {
    if (url.isEmpty) return null;

    try {
      final cacheDir = await _getCacheDirectory();
      final extension = _getFileExtension(url);
      final fileName = "${cacheFileStem(url)}.$extension";
      final filePath = "${cacheDir.path}/$fileName";
      final file = File(filePath);

      if (await file.exists()) {
        onProgress?.call(1.0);
        return file;
      }

      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception("Failed to download file: ${response.statusCode}");
      }

      final totalBytes = response.contentLength ?? 0;
      final sink = file.openWrite();
      int receivedBytes = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call(receivedBytes / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();
      onProgress?.call(1.0);
      return file;
    } catch (e) {
      debugPrint("❌ Download with progress failed for $url: $e");
      return null;
    }
  }

  Future<File> _download(String url) async {
    final cacheDir = await _getCacheDirectory();
    final extension = _getFileExtension(url);
    final fileName = "${cacheFileStem(url)}.$extension";
    final filePath = "${cacheDir.path}/$fileName";
    final file = File(filePath);

    debugPrint("⬇️ Downloading: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      debugPrint("✅ Cached: $filePath");
      return file;
    } else {
      throw Exception("Failed to download file: ${response.statusCode}");
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory("${tempDir.path}/chat_media_cache");
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _getFileExtension(String url) {
    try {
      String extension = url.split('.').last.split('?').first.toLowerCase();
      if (extension.length > 5 || extension.contains('/')) {
        // Fallback or attempt to guess from URL if messy
        if (url.contains("video")) return "mp4";
        if (url.contains("image")) return "jpg";
        return "bin";
      }
      return extension;
    } catch (_) {
      return "bin";
    }
  }

  /// Optional: Clear old cache
  Future<void> clearOldCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        final now = DateTime.now();
        await for (var entity in cacheDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            if (now.difference(stat.modified).inHours > 24) {
              await entity.delete();
              debugPrint("🧹 Deleted expired cache file: ${entity.path}");
            }
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Error clearing cache: $e");
    }
  }
}
