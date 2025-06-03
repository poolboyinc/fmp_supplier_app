import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:fmp_supplier_app/core/config/mapbox_config.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fmp_supplier_app/features/parties/data/models/party_model.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_bloc.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_event.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_state.dart';
import 'package:uuid/uuid.dart';

class CreatePartyPage extends StatefulWidget {
  final String? partyId;

  const CreatePartyPage({Key? key, this.partyId}) : super(key: key);

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _genreController = TextEditingController();
  final _startTimeController = TextEditingController(text: '22:00');
  final _endTimeController = TextEditingController(text: '04:00');
  final _priceController = TextEditingController(text: '€');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  List<String> _selectedTags = [];
  bool _isFeatured = false;

  double _latitude = MapboxConfig.initialLatitude;
  double _longitude = MapboxConfig.initialLongitude;

  File? _imageFile;
  File? _logoFile;
  String _imageUrl = '';
  String _logoUrl = '';

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  bool _isMapReady = false;
  bool _isMarkerPlaced = false;

  bool _isLoading = false;
  bool _isEditMode = false;
  PartyModel? _party;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.partyId != null;

    if (_isEditMode) {
      _loadParty();
    }
  }

  Future<void> _loadParty() async {
    if (widget.partyId == null) return;

    setState(() {
      _isLoading = true;
    });

    context.read<PartyBloc>().add(GetPartyEvent(widget.partyId!));
  }

  void _onPartyLoaded(PartyModel party) {
    setState(() {
      _party = party;
      _nameController.text = party.name;
      _descriptionController.text = party.description;
      _venueController.text = party.venue;
      _genreController.text = party.genre;
      _selectedDate = party.date;
      _startTimeController.text = party.startTime;
      _endTimeController.text = party.endTime;
      _priceController.text = party.priceCategory;
      _latitude = party.latitude;
      _longitude = party.longitude;
      _imageUrl = party.imageUrl;
      _logoUrl = party.logoUrl;
      _selectedTags = List.from(party.tags);
      _isFeatured = party.isFeatured;

      _isLoading = false;
    });

    if (_isMapReady && _mapboxMap != null) {
      _centerMapOnLocation();
      _addMarkerAtLocation(_party!.longitude, _party!.latitude);
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _mapboxMap!.loadStyleURI(MapboxConfig.styleUrl);

    setState(() {
      _isMapReady = true;
    });

    _centerMapOnLocation();

    if (_isEditMode && _party != null) {
      _addMarkerAtLocation(_party!.longitude, _party!.latitude);
    }
  }

  // Handle map taps
  void _onMapTapped(MapContentGestureContext context) {
    setState(() {
      _latitude = context.point.coordinates.lat.toDouble();
      _longitude = context.point.coordinates.lng.toDouble();
      _isMarkerPlaced = true;
    });

    _addMarkerAtLocation(_longitude, _latitude);
  }

  void _centerMapOnLocation() {
    if (_mapboxMap == null) return;

    _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(_longitude, _latitude)),
        zoom: 15.0,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _addMarkerAtLocation([
    double? longitude,
    double? latitude,
  ]) async {
    if (_mapboxMap == null || !_isMapReady) return;

    // Use provided coordinates or current coordinates
    final lon = longitude ?? _longitude;
    final lat = latitude ?? _latitude;

    // Clear existing markers
    if (_pointAnnotationManager != null) {
      await _pointAnnotationManager!.deleteAll();
    } else {
      _pointAnnotationManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();
    }

    // Create a marker at the specified location
    final geometry = Point(coordinates: Position(lon, lat));

    // Create marker options with default marker styling
    final options = PointAnnotationOptions(
      geometry: geometry,
      iconSize: 1.0,
      iconColor: Colors.red.value, // Use a red marker
    );

    await _pointAnnotationManager!.create(options);

    setState(() {
      _isMarkerPlaced = true;
    });
  }

  Future<void> _pickImage(bool isLogo) async {
    final img_picker.ImagePicker picker = img_picker.ImagePicker();
    final img_picker.XFile? image = await picker.pickImage(
      source: img_picker.ImageSource.gallery, // Fixed ambiguous import
      maxWidth: isLogo ? 500 : 1200,
      maxHeight: isLogo ? 500 : 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(image.path);
        } else {
          _imageFile = File(image.path);
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: Color(0xFF212121),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    // Parse the current time from the controller
    final TimeOfDay initialTime = _parseTimeString(controller.text);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: Color(0xFF212121),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final String formattedTime = _formatTimeOfDay(pickedTime);
      controller.text = formattedTime;
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveParty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isMarkerPlaced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // First upload images if needed
    if (_imageFile != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.jpg';
      context.read<PartyBloc>().add(
        UploadPartyImageEvent(_imageFile!.path, fileName),
      );
      return; // Will continue in the bloc listener after image upload
    }

    if (_logoFile != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.jpg';
      context.read<PartyBloc>().add(
        UploadPartyLogoEvent(_logoFile!.path, fileName),
      );
      return; // Will continue in the bloc listener after logo upload
    }

    // If no images to upload, proceed to save party
    _finalizePartySave();
  }

  void _finalizePartySave() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please log in again.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final party = PartyModel(
      id: _isEditMode ? _party!.id : '',
      name: _nameController.text,
      description: _descriptionController.text,
      venue: _venueController.text,
      genre: _genreController.text,
      latitude: _latitude,
      longitude: _longitude,
      date: _selectedDate,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      imageUrl: _imageUrl,
      logoUrl: _logoUrl,
      rating: _isEditMode ? _party!.rating : 0.0,
      reviewCount: _isEditMode ? _party!.reviewCount : 0,
      priceCategory: _priceController.text,
      tags: _selectedTags,
      isFeatured: _isFeatured,
      ownerId: authState.userId,
    );

    if (_isEditMode) {
      context.read<PartyBloc>().add(UpdatePartyEvent(party));
    } else {
      context.read<PartyBloc>().add(CreatePartyEvent(party));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Party' : 'Create Party'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveParty,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<PartyBloc, PartyState>(
        listener: (context, state) {
          if (state is PartyLoaded && _isEditMode) {
            _onPartyLoaded(state.party as PartyModel);
          } else if (state is PartyError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is ImageUploaded) {
            if (state.isLogo) {
              setState(() {
                _logoUrl = state.imageUrl;
                _logoFile = null;
              });

              // If both images are now uploaded, save the party
              if (_imageFile == null) {
                _finalizePartySave();
              } else {
                // Upload the other image
                final fileName =
                    '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.jpg';
                context.read<PartyBloc>().add(
                  UploadPartyImageEvent(_imageFile!.path, fileName),
                );
              }
            } else {
              setState(() {
                _imageUrl = state.imageUrl;
                _imageFile = null;
              });

              // If both images are now uploaded, save the party
              if (_logoFile == null) {
                _finalizePartySave();
              } else {
                // Upload the other image
                final fileName =
                    '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.jpg';
                context.read<PartyBloc>().add(
                  UploadPartyLogoEvent(_logoFile!.path, fileName),
                );
              }
            }
          } else if (state is PartyCreated || state is PartyUpdated) {
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Party updated successfully'
                      : 'Party created successfully',
                ),
                backgroundColor: AppTheme.success,
              ),
            );

            Navigator.pop(context, true); // Return success
          }
        },
        child:
            _isLoading && _isEditMode && _party == null
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Info Section
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Party Name',
                            hintText: 'Enter a catchy name for your party',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a party name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Describe your party',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _venueController,
                          decoration: const InputDecoration(
                            labelText: 'Venue Name',
                            hintText: 'Where is the party being held?',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a venue name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _genreController,
                          decoration: const InputDecoration(
                            labelText: 'Music Genre',
                            hintText: 'e.g. House, Techno, Hip-Hop',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a music genre';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Date & Time Section
                        const Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Party Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat(
                                'EEEE, MMMM d, yyyy',
                              ).format(_selectedDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(_startTimeController),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Time',
                                    suffixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(_startTimeController.text),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(_endTimeController),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'End Time',
                                    suffixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(_endTimeController.text),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Location Section
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap on the map to set the party location',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.textGrey),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: MapWidget(
                            styleUri: MapboxConfig.styleUrl,
                            mapOptions: MapOptions(
                              constrainMode: ConstrainMode.HEIGHT_ONLY,
                              contextMode: ContextMode.UNIQUE,
                              pixelRatio:
                                  MediaQuery.of(context).devicePixelRatio,
                            ),
                            cameraOptions: CameraOptions(
                              center: Point(
                                coordinates: Position(
                                  MapboxConfig.initialLongitude,
                                  MapboxConfig.initialLatitude,
                                ),
                              ),
                              zoom: MapboxConfig.initialZoom,
                            ),
                            onMapCreated: _onMapCreated,
                            onTapListener:
                                _onMapTapped, // Add this line for tap handling
                          ),
                        ),
                        if (_isMarkerPlaced)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Location: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        const Text(
                          'Party Images',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cover Image'),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _pickImage(false),
                                    child: Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                      child:
                                          _imageFile != null
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  _imageFile!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              )
                                              : _imageUrl.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  _imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 40,
                                                        color:
                                                            AppTheme.textGrey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                              : const Center(
                                                child: Icon(
                                                  Icons.add_photo_alternate,
                                                  size: 40,
                                                  color: AppTheme.textGrey,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Logo/Icon'),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _pickImage(true),
                                    child: Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.textGrey,
                                        ),
                                      ),
                                      child:
                                          _logoFile != null
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  _logoFile!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              )
                                              : _logoUrl.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  _logoUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 40,
                                                        color:
                                                            AppTheme.textGrey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                              : const Center(
                                                child: Icon(
                                                  Icons.add_photo_alternate,
                                                  size: 40,
                                                  color: AppTheme.textGrey,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price Category',
                            hintText: 'e.g. €, €€, €€€',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Featured Party'),
                          subtitle: const Text(
                            'Featured parties appear at the top of search results',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          value: _isFeatured,
                          activeColor: AppTheme.primaryPurple,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            setState(() {
                              _isFeatured = value;
                            });
                          },
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveParty,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      _isEditMode
                                          ? 'Update Party'
                                          : 'Create Party',
                                    ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _genreController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
