import 'package:flutter/material.dart';

import 'app_image_box.dart';

// top image used on login and register screens
class AuthHeroImage extends StatelessWidget {
  const AuthHeroImage({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F8FC),
      child: AspectRatio(
        aspectRatio: 853 / 533,
        child: AppImageBox(
          imagePath: imagePath,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          fallback: const Center(
            child: Text(
              'TP Go!',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Color(0xFF070B55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}