import 'package:dartz/dartz.dart';
import 'package:fmp_supplier_app/core/errors/failures.dart';
import 'package:fmp_supplier_app/features/bookings/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<BookingEntity>>> getPartyBookings(String partyId);
  Future<Either<Failure, List<BookingEntity>>> getOwnerBookings(String ownerId);
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String status,
  );
}
