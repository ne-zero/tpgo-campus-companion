import 'package:flutter/material.dart';

// fallback used on platforms where local file images are unavailable
Widget buildLocalImage({
  required String path,
  required double height,
  required double width,
  required BoxFit fit,
  required Widget fallback,
}) {
  return fallback;
}