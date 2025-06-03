import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:fmp_supplier_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fmp_supplier_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fmp_supplier_app/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:fmp_supplier_app/features/bookings/domain/repositories/booking_repository.dart';
import 'package:fmp_supplier_app/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:fmp_supplier_app/features/parties/data/repositories/party_repository_impl.dart';
import 'package:fmp_supplier_app/features/parties/domain/repositories/party_repository.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth, firestore),
  );

  sl.registerLazySingleton<PartyRepository>(
    () => PartyRepositoryImpl(firestore, storage),
  );

  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(firestore),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));

  sl.registerFactory<PartyBloc>(() => PartyBloc(partyRepository: sl()));

  sl.registerFactory<BookingBloc>(() => BookingBloc(bookingRepository: sl()));
}
