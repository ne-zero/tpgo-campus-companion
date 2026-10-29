import 'dart:io';

import 'package:flutter/material.dart';

// displays an image stored inside the device
Widget buildLocalImage({
  required String path,
  required double height,
  required double width,
  required BoxFit fit,
  required Widget fallback,
}) {
  return Image.file(
    File(path),
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (
      context,
      error,
      stackTrace,
    ) {
      return fallback;
    },
  );
}