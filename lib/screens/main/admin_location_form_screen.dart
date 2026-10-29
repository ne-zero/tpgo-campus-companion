import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';

import '../../models/campus_location.dart';
import '../../services/notification_service.dart';
import '../../widgets/campus_map.dart';

const List<String> _statusOptions = [
  'Open',
  'Busy',
  'Closed',
  'Under Renovation',
];

const List<String> _crowdOptions = [
  'Low',
  'Medium',
  'High',
];

// icon used for each location category
const Map<String, IconData> _categoryIcons = {
  'Food': Icons.restaurant,
  'Study': Icons.menu_book,
  'Prayer': Icons.mosque,
  'Sports': Icons.sports_basketball,
  'Facilities': Icons.business,
};

// colour used for each location category
const Map<String, Color> _categoryColors = {
  'Food': Color(0xFFE8590C),
  'Study': Color(0xFF2637FF),
  'Prayer': Color(0xFF0F9D58),
  'Sports': Color(0xFFD6336C),
  'Facilities': Color(0xFF6B3DFF),
};

Color _statusColor(String status) {
  if (status == 'Open') {
    return const Color(0xFF18B337);
  }

  if (status == 'Busy') {
    return const Color(0xFFFF9800);
  }

  return const Color(0xFFE53935);
}

Color _crowdColor(String crowd) {
  if (crowd == 'Low') {
    return const Color(0xFF18B337);
  }

  if (crowd == 'Medium') {
    return const Color(0xFFFF9800);
  }

  return const Color(0xFFE53935);
}

// used by admin to create or edit campus locations
class AdminLocationFormScreen extends StatefulWidget {
  const AdminLocationFormScreen({
    super.key,
    this.existingLocation,
  });

  final CampusLocation? existingLocation;

  static const String routeName = '/admin-location-form';

  @override
  State<AdminLocationFormScreen> createState() {
    return _AdminLocationFormScreenState();
  }
}

class _AdminLocationFormScreenState
    extends State<AdminLocationFormScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _distanceController;

  late String _selectedCategory;
  late String _selectedStatus;
  late String _selectedCrowd;
  late LatLng _selectedMapPosition;

  File? _pickedImageFile;

  bool _isSaving = false;

  bool get _isEditing {
    return widget.existingLocation != null;
  }

  @override
  void initState() {
    super.initState();

    final location = widget.existingLocation;

    _nameController = TextEditingController(
      text: location?.name ?? '',
    );

    _descriptionController = TextEditingController(
      text: location?.description ?? '',
    );

    _distanceController = TextEditingController(
      text: location?.distance ?? '',
    );

    _selectedCategory =
        location?.category ?? 'Food';

    _selectedStatus =
        location?.status ?? 'Open';

    _selectedCrowd =
        location?.crowdLevel ?? 'Low';

    _selectedMapPosition = LatLng(
      location?.latitude ?? CampusMap.campusCenter.latitude,
      location?.longitude ?? CampusMap.campusCenter.longitude,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _distanceController.dispose();

    super.dispose();
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : const Color(0xFF2637FF),
      ),
    );
  }

  // allows admin to choose a photo
  Future<void> _pickImage(
    ImageSource source,
  ) async {
    try {
      final XFile? picked =
          await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );

      if (picked == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _pickedImageFile = File(
          picked.path,
        );
      });
    } catch (error) {
      _showMessage(
        source == ImageSource.camera
            ? 'Could not open the camera.'
            : 'Could not open the gallery.',
        isError: true,
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                ),
                title: const Text(
                  'Take a photo',
                ),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  _pickImage(
                    ImageSource.camera,
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text(
                  'Choose from gallery',
                ),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  _pickImage(
                    ImageSource.gallery,
                  );
                },
              ),

              if (_pickedImageFile != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove selected photo',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    setState(() {
                      _pickedImageFile = null;
                    });
                  },
                ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // copies the selected image into tp go's private local folder
  Future<String> _saveImageLocally(
    File originalFile,
  ) async {
    final Directory appDirectory =
        await getApplicationDocumentsDirectory();

    final Directory imageDirectory =
        Directory(
      '${appDirectory.path}/location_images',
    );

    // creates the folder the first time
    if (!await imageDirectory.exists()) {
      await imageDirectory.create(
        recursive: true,
      );
    }

    final String fileName =
        'location_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final String newPath =
        '${imageDirectory.path}/$fileName';

    final File savedFile =
        await originalFile.copy(
      newPath,
    );

    return savedFile.path;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String imagePath =
          widget.existingLocation?.imagePath ??
              'images/tp_campus.jpg';

      // if admin selected a new photo, save it locally
      if (_pickedImageFile != null) {
        imagePath =
            await _saveImageLocally(
          _pickedImageFile!,
        );
      }

      final IconData icon =
          _categoryIcons[_selectedCategory] ??
              Icons.place;

      final Color color =
          _categoryColors[_selectedCategory] ??
              const Color(0xFF2637FF);

      final Map<String, dynamic> data = {
        'name':
            _nameController.text.trim(),
        'category':
            _selectedCategory,
        'crowdLevel':
            _selectedCrowd,
        'distance':
            _distanceController.text.trim(),
        'status':
            _selectedStatus,
        'description':
            _descriptionController.text.trim(),
        'imagePath':
            imagePath,
        'tags': [
          _selectedCategory,
        ],
        'iconCode':
            icon.codePoint,
        'colorValue':
            color.toARGB32(),
        'latitude': _selectedMapPosition.latitude,
        'longitude': _selectedMapPosition.longitude,
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      final collection =
          FirebaseFirestore.instance
              .collection(
        'campusLocations',
      );

      if (_isEditing) {
        final CampusLocation original =
            widget.existingLocation!;

        await collection
            .doc(original.id)
            .update(data);

        final bool statusChanged =
            _selectedStatus !=
                original.status;

        final bool crowdChanged =
            _selectedCrowd !=
                original.crowdLevel;

        // notify for every status change
        if (statusChanged) {
          await NotificationService()
              .notifyLocationStatusChange(
            locationName:
                _nameController.text.trim(),
            newStatus:
                _selectedStatus,
          );
        }

        // notify for every crowd change
        if (crowdChanged) {
          await NotificationService()
              .notifyCrowdLevelChange(
            locationName:
                _nameController.text.trim(),
            newCrowd:
                _selectedCrowd,
          );
        }
      } else {
        await collection.add({
          ...data,
          'createdAt':
              FieldValue.serverTimestamp(),
        });

        await NotificationService()
            .notifyNewLocation(
          _nameController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not save: ${error.message ?? error.code}',
        isError: true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildImagePicker() {
    final String? existingPath =
        widget.existingLocation?.imagePath;

    return GestureDetector(
      onTap: _isSaving
          ? null
          : _showImageSourceSheet,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              const Color(0xFFEEF0FA),
          borderRadius:
              BorderRadius.circular(20),
        ),
        clipBehavior:
            Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // newly selected image
            if (_pickedImageFile != null)
              Image.file(
                _pickedImageFile!,
                fit: BoxFit.cover,
              )

            // existing local image
            else if (existingPath != null &&
                existingPath.isNotEmpty &&
                !existingPath.startsWith(
                  'images/',
                ) &&
                !existingPath.startsWith(
                  'http',
                ))
              Image.file(
                File(existingPath),
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildAddPhotoPlaceholder();
                },
              )

            // old network image, if any existed before storage was removed
            else if (existingPath != null &&
                existingPath.startsWith(
                  'http',
                ))
              Image.network(
                existingPath,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildAddPhotoPlaceholder();
                },
              )

            // normal app asset
            else if (existingPath != null &&
                existingPath.startsWith(
                  'images/',
                ))
              Image.asset(
                existingPath,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _buildAddPhotoPlaceholder();
                },
              )

            else
              _buildAddPhotoPlaceholder(),

            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: 0.55,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 14,
                      color:
                          Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Change photo',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
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

  Widget _buildAddPhotoPlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 36,
            color:
                Color(0xFF6B3DFF),
          ),
          SizedBox(height: 8),
          Text(
            'Add a photo',
            style: TextStyle(
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF6B3DFF),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Stored on this device',
            style: TextStyle(
              fontSize: 11,
              color:
                  Color(0xFF9CA3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight:
              FontWeight.w800,
          fontSize: 13,
          color:
              Color(0xFF9CA3B8),
        ),
      ),
    );
  }

  Widget _chipRow<T>({
    required List<T> options,
    required T selected,
    required String Function(T) label,
    required Color Function(T) color,
    required void Function(T) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map(
        (option) {
          final bool isSelected =
              option == selected;

          final Color c =
              color(option);

          return GestureDetector(
            onTap: () {
              onSelected(option);
            },
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 150,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration:
                  BoxDecoration(
                color: isSelected
                    ? c
                    : c.withValues(
                        alpha: 0.1,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color: c,
                  width:
                      isSelected ? 0 : 1.2,
                ),
              ),
              child: Text(
                label(option),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : c,
                  fontWeight:
                      FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _isEditing
              ? 'Edit Location'
              : 'Add Location',
          style: const TextStyle(
            fontWeight:
                FontWeight.w900,
            color:
                Color(0xFF080C3F),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              _buildImagePicker(),

              _sectionTitle('NAME'),

              TextFormField(
                controller:
                    _nameController,
                decoration:
                    const InputDecoration(
                  hintText:
                      'e.g. Breadboard Café',
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter a name.';
                  }

                  return null;
                },
              ),

              _sectionTitle(
                'CATEGORY',
              ),

              _chipRow<String>(
                options:
                    locationCategories
                        .where(
                          (category) =>
                              category !=
                              'All',
                        )
                        .toList(),
                selected:
                    _selectedCategory,
                label:
                    (category) =>
                        category,
                color: (category) =>
                    _categoryColors[
                        category] ??
                    const Color(
                      0xFF2637FF,
                    ),
                onSelected:
                    (category) {
                  setState(() {
                    _selectedCategory =
                        category;
                  });
                },
              ),

              _sectionTitle(
                'DESCRIPTION',
              ),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  hintText:
                      'What makes this place worth visiting?',
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter a description.';
                  }

                  return null;
                },
              ),

              _sectionTitle(
                'DISTANCE',
              ),

              TextFormField(
                controller:
                    _distanceController,
                decoration:
                    const InputDecoration(
                  hintText:
                      'e.g. 3 min walk',
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter a distance.';
                  }

                  return null;
                },
              ),

              _sectionTitle(
                'STATUS',
              ),

              _chipRow<String>(
                options:
                    _statusOptions,
                selected:
                    _selectedStatus,
                label:
                    (status) => status,
                color:
                    _statusColor,
                onSelected: (status) {
                  setState(() {
                    _selectedStatus =
                        status;
                  });
                },
              ),

              _sectionTitle(
                'CROWD LEVEL',
              ),

              _chipRow<String>(
                options:
                    _crowdOptions,
                selected:
                    _selectedCrowd,
                label:
                    (crowd) => crowd,
                color:
                    _crowdColor,
                onSelected: (crowd) {
                  setState(() {
                    _selectedCrowd =
                        crowd;
                  });
                },
              ),

              _sectionTitle(
                'MAP POSITION',
              ),

              CampusMap(
                locations: const [],
                height: 280,
                selectionMode: true,
                selectedPosition:
                    _selectedMapPosition,
                onPositionSelected: (position) {
                  setState(() {
                    _selectedMapPosition = position;
                  });
                },
              ),

              const SizedBox(height: 8),

              Text(
                'Tap the map to place the pin for this location.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 56,
                child:
                    ElevatedButton(
                  onPressed:
                      _isSaving
                          ? null
                          : _save,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2637FF,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing
                              ? 'Save Changes'
                              : 'Add Location',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}