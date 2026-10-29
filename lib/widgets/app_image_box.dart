import 'package:flutter/material.dart';

import 'local_image.dart';

// reusable image widget used throughout tp go
// supports:
// 1. bundled app assets
// 2. network images
// 3. locally picked images stored on android
class AppImageBox extends StatelessWidget {
  const AppImageBox({
    super.key,
    required this.imagePath,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  });

  final String imagePath;
  final double height;
  final double width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  bool get _isNetworkImage {
    return imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');
  }

  bool get _isAssetImage {
    return imagePath.startsWith('images/');
  }

  Widget _buildFallback() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: fallback ??
            const Icon(
              Icons.image_outlined,
              color: Color(0xFF2637FF),
              size: 40,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallbackWidget =
        _buildFallback();

    Widget image;

    // firebase / online image
    if (_isNetworkImage) {
      image = Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (
          context,
          child,
          progress,
        ) {
          if (progress == null) {
            return child;
          }

          return Container(
            height: height,
            width: width,
            color:
                const Color(0xFFEAF0FF),
            child: const Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return fallbackWidget;
        },
      );
    }

    // normal image from project images folder
    else if (_isAssetImage) {
      image = Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return fallbackWidget;
        },
      );
    }

    // locally selected image on android
    else {
      image = buildLocalImage(
        path: imagePath,
        height: height,
        width: width,
        fit: fit,
        fallback: fallbackWidget,
      );
    }

    return ClipRRect(
      borderRadius:
          borderRadius ??
              BorderRadius.zero,
      child: image,
    );
  }
}