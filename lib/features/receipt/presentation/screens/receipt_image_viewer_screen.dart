import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Full-screen receipt image viewer with pinch-to-zoom.
///
/// Supports both URL images (http/https) and base64 data strings.
class ReceiptImageViewerScreen extends StatelessWidget {
  final String title;
  final String source;

  const ReceiptImageViewerScreen({
    super.key,
    required this.title,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final isUrl = source.startsWith('http://') || source.startsWith('https://');

    ImageProvider? provider;
    if (isUrl) {
      provider = NetworkImage(source);
    } else {
      String base64Data = source.trim();
      if (base64Data.contains(',')) base64Data = base64Data.split(',').last;
      try {
        provider = MemoryImage(base64Decode(base64Data));
      } catch (_) {
        provider = null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.mitsuiDarkBlue,
      ),
      body: provider == null
          ? Center(
              child: Text(
                'Unable to load image',
                style: TextStyle(color: Colors.grey.shade300),
              ),
            )
          : SafeArea(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                panEnabled: true,
                scaleEnabled: true,
                child: Center(
                  child: Image(
                    image: provider,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        'Unable to load image',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      final expected = loadingProgress.expectedTotalBytes;
                      final loaded = loadingProgress.cumulativeBytesLoaded;
                      final value =
                          expected == null ? null : loaded / expected;
                      return Center(
                        child: CircularProgressIndicator(
                          value: value,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

