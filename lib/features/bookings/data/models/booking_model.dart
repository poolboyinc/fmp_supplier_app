import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fmp_supplier_app/features/bookings/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required String id,
    required String partyId,
    required String userId,
    required String userName,
    required String userEmail,
    required DateTime bookingDate,
    required int ticketCount,
    required double totalAmount,
    required String status,
  }) : super(
         id: id,
         partyId: partyId,
         userId: userId,
         userName: userName,
         userEmail: userEmail,
         bookingDate: bookingDate,
         ticketCount: ticketCount,
         totalAmount: totalAmount,
         status: status,
       );

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      partyId: json['partyId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      bookingDate:
          (json['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ticketCount: (json['ticketCount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partyId': partyId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'ticketCount': ticketCount,
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
