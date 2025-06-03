import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fmp_supplier_app/features/bookings/domain/repositories/booking_repository.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_event.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;

  BookingBloc({required this.bookingRepository}) : super(BookingInitial()) {
    on<GetPartyBookingsEvent>(_onGetPartyBookings);
    on<GetOwnerBookingsEvent>(_onGetOwnerBookings);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
  }

  Future<void> _onGetPartyBookings(
    GetPartyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getPartyBookings(event.partyId);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onGetOwnerBookings(
    GetOwnerBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await bookingRepository.getOwnerBookings(event.ownerId);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await bookingRepository.updateBookingStatus(
      event.bookingId,
      event.status,
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (_) => emit(BookingStatusUpdated()),
    );
  }
}
