import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fmp_supplier_app/features/bookings/domain/entities/booking_entity.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_event.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_state.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/widgets/booking_card.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<BookingBloc>().add(GetOwnerBookingsEvent(authState.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
          ],
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingsLoaded) {
            final allBookings = state.bookings;

            if (allBookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 64,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookings yet',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppTheme.textGrey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bookings for your parties will appear here',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  ],
                ),
              );
            }

            // Filter bookings based on tab
            final pendingBookings =
                allBookings.where((b) => b.status == 'pending').toList();
            final confirmedBookings =
                allBookings.where((b) => b.status == 'confirmed').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // All bookings tab
                _buildBookingsList(allBookings),

                // Pending bookings tab
                _buildBookingsList(pendingBookings),

                // Confirmed bookings tab
                _buildBookingsList(confirmedBookings),
              ],
            );
          } else if (state is BookingError) {
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
                    'Error loading bookings',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppTheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadBookings,
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
    );
  }

  Widget _buildBookingsList(List<BookingEntity> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: AppTheme.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings in this category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textGrey),
            ),
          ],
        ),
      );
    }

    // Group bookings by date
    final groupedBookings = _groupBookingsByDate(bookings);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedBookings.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedBookings.keys.elementAt(index);
        final bookingsForDate = groupedBookings[dateGroup]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                dateGroup,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookingsForDate.length,
              itemBuilder: (context, i) {
                return BookingCard(
                  booking: bookingsForDate[i],
                  onStatusChange: (String status) {
                    context.read<BookingBloc>().add(
                      UpdateBookingStatusEvent(bookingsForDate[i].id, status),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Map<String, List<BookingEntity>> _groupBookingsByDate(
    List<BookingEntity> bookings,
  ) {
    final Map<String, List<BookingEntity>> grouped = {};

    for (final booking in bookings) {
      // Format the date
      final dateStr = DateFormat('MMMM d, yyyy').format(booking.bookingDate);

      // Add to group
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(booking);
    }

    // Sort dates (most recent first)
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          // Parse the date strings for comparison
          final dateFormat = DateFormat('MMMM d, yyyy');
          final dateA = dateFormat.parse(a);
          final dateB = dateFormat.parse(b);
          return dateB.compareTo(dateA);
        });

    // Create a new sorted map
    final Map<String, List<BookingEntity>> sortedMap = {};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
