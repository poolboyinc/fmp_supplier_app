import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:fmp_supplier_app/core/config/mapbox_config.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_event.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_state.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_bloc.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_event.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_state.dart';

class PartyDetailsPage extends StatefulWidget {
  final String partyId;

  const PartyDetailsPage({Key? key, required this.partyId}) : super(key: key);

  @override
  State<PartyDetailsPage> createState() => _PartyDetailsPageState();
}

class _PartyDetailsPageState extends State<PartyDetailsPage> {
  MapboxMap? _mapboxMap;
  bool _isMapReady = false;
  PointAnnotationManager? _pointAnnotationManager;
  bool _isLoading = true;
  bool _showBookings = false;

  @override
  void initState() {
    super.initState();
    _loadParty();
  }

  void _loadParty() {
    context.read<PartyBloc>().add(GetPartyEvent(widget.partyId));
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _mapboxMap!.loadStyleURI(MapboxConfig.styleUrl);

    setState(() {
      _isMapReady = true;
    });

    _centerMapOnParty();
  }

  void _centerMapOnParty() {
    if (_mapboxMap == null || !_isMapReady) return;

    final state = context.read<PartyBloc>().state;
    if (state is PartyLoaded) {
      final party = state.party;

      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(party.longitude, party.latitude)),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 500),
      );

      _addMarkerAtLocation(party.longitude, party.latitude);
    }
  }

  Future<void> _addMarkerAtLocation(double longitude, double latitude) async {
    if (_mapboxMap == null || !_isMapReady) return;

    if (_pointAnnotationManager != null) {
      await _pointAnnotationManager!.deleteAll();
    } else {
      _pointAnnotationManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();
    }

    final geometry = Point(coordinates: Position(longitude, latitude));

    final options = PointAnnotationOptions(
      geometry: geometry,
      iconSize: 1.0,
      iconImage: "assets/images/location_pin.png",
    );

    await _pointAnnotationManager!.create(options);
  }

  void _toggleBookings() {
    setState(() {
      _showBookings = !_showBookings;
    });

    if (_showBookings) {
      context.read<BookingBloc>().add(GetPartyBookingsEvent(widget.partyId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PartyBloc, PartyState>(
        listener: (context, state) {
          if (state is PartyLoaded) {
            setState(() {
              _isLoading = false;
            });

            if (_isMapReady && _mapboxMap != null) {
              _centerMapOnParty();
            }
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
          } else if (state is PartyDeleted) {
            Navigator.pop(context, true);
          }
        },
        child: BlocBuilder<PartyBloc, PartyState>(
          builder: (context, state) {
            if (_isLoading || state is PartyLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PartyLoaded) {
              final party = state.party;

              return CustomScrollView(
                slivers: [
                  // App Bar with party image
                  SliverAppBar(
                    expandedHeight: 200.0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          party.imageUrl.isNotEmpty
                              ? Image.network(
                                party.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                ),
                              ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-party',
                            arguments: party.id,
                          ).then((result) {
                            if (result == true) {
                              _loadParty();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ],
                  ),

                  // Party details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (party.logoUrl.isNotEmpty)
                                Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(party.logoUrl),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      party.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            party.genre,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (party.isFeatured)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentPink
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppTheme.accentPink,
                                                width: 1,
                                              ),
                                            ),
                                            child: const Text(
                                              'Featured',
                                              style: TextStyle(
                                                color: AppTheme.accentPink,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Date and time info
                          const Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            title: 'Date',
                            value: DateFormat(
                              'EEEE, MMMM d, yyyy',
                            ).format(party.date),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.access_time,
                            title: 'Time',
                            value: '${party.startTime} - ${party.endTime}',
                          ),

                          const SizedBox(height: 24),

                          // Location info
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.location_on,
                            title: 'Venue',
                            value: party.venue,
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
                              mapOptions: MapOptions(
                                constrainMode: ConstrainMode.HEIGHT_ONLY,
                                contextMode: ContextMode.UNIQUE,
                                pixelRatio:
                                    MediaQuery.of(context).devicePixelRatio,
                              ),
                              styleUri: MapboxConfig.styleUrl,
                              cameraOptions: CameraOptions(
                                center: Point(
                                  coordinates: Position(
                                    party.longitude,
                                    party.latitude,
                                  ),
                                ),
                                zoom: 15.0,
                              ),
                              onMapCreated: _onMapCreated,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            party.description,
                            style: const TextStyle(height: 1.5),
                          ),

                          const SizedBox(height: 24),

                          // Additional info
                          const Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.attach_money,
                            title: 'Price Category',
                            value: party.priceCategory,
                          ),
                          if (party.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.tag,
                              title: 'Tags',
                              value: party.tags.join(', '),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Stats
                          const Text(
                            'Stats',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatCard(
                                icon: Icons.star,
                                value: party.rating.toStringAsFixed(1),
                                label: 'Rating',
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                icon: Icons.reviews,
                                value: party.reviewCount.toString(),
                                label: 'Reviews',
                                color: AppTheme.accentBlue,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Bookings section
                          ElevatedButton.icon(
                            onPressed: _toggleBookings,
                            icon: Icon(
                              _showBookings
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            label: Text(
                              _showBookings ? 'Hide Bookings' : 'View Bookings',
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppTheme.textLight,
                              backgroundColor: AppTheme.primaryPurple,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                            ),
                          ),

                          if (_showBookings) ...[
                            const SizedBox(height: 16),
                            _buildBookingsList(),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is PartyError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading party',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppTheme.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadParty,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is BookingsLoaded) {
          final bookings = state.bookings;

          if (bookings.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No bookings for this party yet',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
              ),
            );
          }

          // Group by status
          final confirmed =
              bookings.where((b) => b.status == 'confirmed').length;
          final pending = bookings.where((b) => b.status == 'pending').length;
          final cancelled =
              bookings.where((b) => b.status == 'cancelled').length;

          // Calculate total revenue
          final totalRevenue = bookings
              .where((b) => b.status == 'confirmed')
              .fold(0.0, (sum, item) => sum + item.totalAmount);

          // Calculate total tickets
          final totalTickets = bookings
              .where((b) => b.status == 'confirmed')
              .fold(0, (sum, item) => sum + item.ticketCount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Booking Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${bookings.length} total',
                          style: const TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatusIndicator(
                          'Confirmed',
                          confirmed,
                          AppTheme.success,
                        ),
                        _buildStatusIndicator(
                          'Pending',
                          pending,
                          AppTheme.warning,
                        ),
                        _buildStatusIndicator(
                          'Cancelled',
                          cancelled,
                          AppTheme.error,
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Revenue',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '€${totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Tickets Sold',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              totalTickets.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Recent Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // List of most recent bookings (limited to 5)
              ...bookings
                  .take(5)
                  .map((booking) => _buildBookingItem(booking))
                  .toList(),

              if (bookings.length > 5) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigate to full bookings list
                      Navigator.pushNamed(context, '/bookings');
                    },
                    icon: const Icon(Icons.list),
                    label: Text('View all ${bookings.length} bookings'),
                  ),
                ),
              ],
            ],
          );
        } else if (state is BookingError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.error,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading bookings: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.error),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    context.read<BookingBloc>().add(
                      GetPartyBookingsEvent(widget.partyId),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(dynamic booking) {
    final formattedDate = DateFormat(
      'MMM d, h:mm a',
    ).format(booking.bookingDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(booking.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(booking.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${booking.ticketCount} tickets • $formattedDate',
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '€${booking.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textGrey;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Party'),
            content: const Text(
              'Are you sure you want to delete this party? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<PartyBloc>().add(
                    DeletePartyEvent(widget.partyId),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
