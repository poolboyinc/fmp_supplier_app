// lib/features/bookings/presentation/widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';
import 'package:fmp_supplier_app/features/bookings/domain/entities/booking_entity.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final Function(String) onStatusChange;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(booking.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    booking.userName.isNotEmpty
                        ? booking.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        booking.userEmail,
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(booking.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _capitalizeStatus(booking.status),
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 8),
                Text(
                  'Booked on ${DateFormat('MMM d, yyyy').format(booking.bookingDate)}',
                  style: const TextStyle(color: AppTheme.textGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number,
                  size: 16,
                  color: AppTheme.textGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${booking.ticketCount} ${booking.ticketCount > 1 ? 'tickets' : 'ticket'}',
                  style: const TextStyle(color: AppTheme.textGrey),
                ),
                const Spacer(),
                Text(
                  '€${booking.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (booking.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => onStatusChange('cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                      ),
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => onStatusChange('confirmed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
          ],
        ),
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

  String _capitalizeStatus(String status) {
    return status.isNotEmpty
        ? status.substring(0, 1).toUpperCase() + status.substring(1)
        : '';
  }
}
