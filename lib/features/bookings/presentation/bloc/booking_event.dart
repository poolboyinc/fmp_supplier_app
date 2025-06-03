import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class GetPartyBookingsEvent extends BookingEvent {
  final String partyId;

  const GetPartyBookingsEvent(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class GetOwnerBookingsEvent extends BookingEvent {
  final String ownerId;

  const GetOwnerBookingsEvent(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatusEvent(this.bookingId, this.status);

  @override
  List<Object?> get props => [bookingId, status];
}
