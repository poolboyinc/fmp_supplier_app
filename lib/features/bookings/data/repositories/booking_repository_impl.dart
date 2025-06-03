import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fmp_supplier_app/core/errors/failures.dart';
import 'package:fmp_supplier_app/features/bookings/data/models/booking_model.dart';
import 'package:fmp_supplier_app/features/bookings/domain/entities/booking_entity.dart';
import 'package:fmp_supplier_app/features/bookings/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<BookingEntity>>> getPartyBookings(
    String partyId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('bookings')
              .where('partyId', isEqualTo: partyId)
              .orderBy('bookingDate', descending: true)
              .get();

      final bookings =
          querySnapshot.docs
              .map(
                (doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();

      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getOwnerBookings(
    String ownerId,
  ) async {
    try {
      // Get all parties owned by this owner
      final partiesSnapshot =
          await _firestore
              .collection('parties')
              .where('ownerId', isEqualTo: ownerId)
              .get();

      final partyIds = partiesSnapshot.docs.map((doc) => doc.id).toList();

      if (partyIds.isEmpty) {
        return const Right([]);
      }

      // Get bookings for all these parties
      final bookingsSnapshot =
          await _firestore
              .collection('bookings')
              .where('partyId', whereIn: partyIds)
              .orderBy('bookingDate', descending: true)
              .get();

      final bookings =
          bookingsSnapshot.docs
              .map(
                (doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();

      return Right(bookings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
