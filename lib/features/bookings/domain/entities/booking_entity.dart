import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String partyId;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime bookingDate;
  final int ticketCount;
  final double totalAmount;
  final String status;

  const BookingEntity({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bookingDate,
    required this.ticketCount,
    required this.totalAmount,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    partyId,
    userId,
    userName,
    userEmail,
    bookingDate,
    ticketCount,
    totalAmount,
    status,
  ];
}
