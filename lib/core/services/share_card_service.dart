import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for capturing Flutter widgets as images and sharing them.
///
/// Uses RepaintBoundary → toImage → PNG pipeline (same as Spotify mobile).
class ShareCardService {
  ShareCardService._();
  static final instance = ShareCardService._();

  /// Capture a widget wrapped in RepaintBoundary as a high-res PNG.
  ///
  /// [boundaryKey] must be attached to a RepaintBoundary widget.
  /// Returns the raw PNG bytes, or null on failure.
  Future<Uint8List?> captureWidget(GlobalKey boundaryKey,
      {double pixelRatio = 3.0}) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ ShareCardService.captureWidget error: $e');
      return null;
    }
  }

  /// Save PNG bytes to a temp file and return the file path.
  Future<File?> _saveTempImage(Uint8List pngBytes, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('❌ ShareCardService._saveTempImage error: $e');
      return null;
    }
  }

  /// Capture a widget and share it via the native share sheet.
  ///
  /// [boundaryKey] must be attached to a RepaintBoundary.
  /// [shareText] is the optional text accompanying the image.
  /// [fileName] is used for the temp file name (without extension).
  Future<bool> captureAndShare(
    GlobalKey boundaryKey, {
    String shareText = 'Check out my cosmic profile on AstroLearn! ✨🔮',
    String fileName = 'astrolearn_share',
  }) async {
    final bytes = await captureWidget(boundaryKey);
    if (bytes == null) return false;

    final file = await _saveTempImage(bytes, fileName);
    if (file == null) return false;

    try {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: shareText,
      );
      return true;
    } catch (e) {
      debugPrint('❌ ShareCardService.captureAndShare error: $e');
      return false;
    }
  }
}
