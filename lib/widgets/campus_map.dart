import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/campus_location.dart';
import 'location_detail_sheet.dart';

// reusable interactive campus map
//
// normal mode:
// tap existing location pins to view details
//
// selection mode:
// admin taps anywhere on the map to choose a location position
class CampusMap extends ConsumerWidget {
  const CampusMap({
    super.key,
    required this.locations,
    this.height = 260,
    this.selectionMode = false,
    this.selectedPosition,
    this.onPositionSelected,
  });

  final List<CampusLocation> locations;
  final double height;

  final bool selectionMode;
  final LatLng? selectedPosition;
  final ValueChanged<LatLng>? onPositionSelected;

  static const LatLng campusCenter =
      LatLng(1.3453, 103.9312);

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final List<Marker> markers = [];

    // existing firestore locations
    for (final location in locations) {
      markers.add(
        Marker(
          point: LatLng(
            location.latitude,
            location.longitude,
          ),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: selectionMode
                ? null
                : () {
                    showLocationDetailSheet(
                      context,
                      ref,
                      location,
                    );
                  },
            child: Container(
              decoration: BoxDecoration(
                color: location.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                location.icon,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),
      );
    }

    // temporary pin used while admin picks a point
    if (selectionMode &&
        selectedPosition != null) {
      markers.add(
        Marker(
          point: selectedPosition!,
          width: 54,
          height: 54,
          child: const Icon(
            Icons.location_pin,
            color: Color(0xFF6B3DFF),
            size: 54,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter:
                    selectedPosition ??
                        campusCenter,
                initialZoom: 16.5,
                minZoom: 14,
                maxZoom: 18.5,

                onTap: selectionMode
                    ? (
                        tapPosition,
                        point,
                      ) {
                        onPositionSelected
                            ?.call(point);
                      }
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.tpgo',
                ),

                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),

            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration:
                    BoxDecoration(
                  color: Theme.of(context).colorScheme.surface
                      .withValues(
                    alpha: 0.92,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      selectionMode
                          ? Icons
                              .location_on_outlined
                          : Icons
                              .touch_app_outlined,
                      size: 15,
                      color:
                          const Color(
                        0xFF2637FF,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      selectionMode
                          ? 'Tap the map to place this location'
                          : 'Tap a pin for details',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}