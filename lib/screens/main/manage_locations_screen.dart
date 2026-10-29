import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/campus_location.dart';
import '../../providers/catalog_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_image_box.dart';
import 'admin_location_form_screen.dart';

Color _statusColor(String status) {
  if (status == 'Open') return const Color(0xFF18B337);
  if (status == 'Busy') return const Color(0xFFFF9800);
  return const Color(0xFFE53935); // Closed, Under Renovation
}

Color _crowdColor(String crowd) {
  if (crowd == 'Low') return const Color(0xFF18B337);
  if (crowd == 'Medium') return const Color(0xFFFF9800);
  return const Color(0xFFE53935);
}

// admin screen: manage campus locations.
// Create + Update happen in AdminLocationFormScreen (full screen, with
// photo upload). This screen is the list + Delete.
class ManageLocationsScreen extends ConsumerWidget {
  const ManageLocationsScreen({super.key});

  static const String routeName = '/admin-locations';

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF2637FF),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CampusLocation location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Remove "${location.name}"?'),
          content: const Text('This deletes the location permanently. This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await FirebaseFirestore.instance.collection('campusLocations').doc(location.id).delete();

      await NotificationService().notifyLocationStatusChange(
        locationName: location.name,
        newStatus: 'Closed',
      );

      if (context.mounted) {
        _showMessage(context, 'Removed "${location.name}".');
      }
    } on FirebaseException catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Could not delete: ${error.message ?? error.code}', isError: true);
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Something went wrong. Please try again.', isError: true);
      }
    }
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, CampusLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminLocationFormScreen(existingLocation: location),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImageBox(
              imagePath: location.imagePath,
              height: 108,
              width: 108,
              fit: BoxFit.cover,
              fallback: Icon(location.icon, color: location.color, size: 32),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location.category,
                      style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildChip(location.status, _statusColor(location.status)),
                        _buildChip('${location.crowdLevel} crowd', _crowdColor(location.crowdLevel)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: () => _confirmDelete(context, location),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(campusLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Manage Locations',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2637FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Location', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AdminLocationFormScreen()),
          );
        },
      ),
      body: SafeArea(
        child: locationsAsync.when(
          data: (locations) {
            if (locations.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No locations yet. Tap "Add Location" to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
              itemCount: locations.length,
              itemBuilder: (context, index) => _buildLocationCard(context, locations[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(child: Text('Could not load locations.')),
        ),
      ),
    );
  }
}
