import 'package:dartz/dartz.dart';
import 'package:fmp_supplier_app/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, bool>> isSignedIn();
  Future<Either<Failure, String>> getCurrentUserId();
}
