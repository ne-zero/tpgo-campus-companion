import 'package:flutter/material.dart';

// one item inside the at a glance section
class HomeStatItem extends StatelessWidget {
  const HomeStatItem({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.title,
    required this.number,
    required this.subtitle,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String title;
  final String number;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: number,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                TextSpan(text: number.isEmpty ? subtitle : ' $subtitle'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}