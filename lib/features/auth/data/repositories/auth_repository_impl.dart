import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fmp_supplier_app/core/errors/failures.dart';
import 'package:fmp_supplier_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Future<Either<Failure, String>> signIn(String email, String password) async {
    try {
      // Authenticate with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user is a supplier
      final userDoc =
          await _firestore
              .collection('suppliers')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        await _firebaseAuth.signOut();
        return Left(AuthFailure('User is not registered as a supplier'));
      }

      return Right(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Right(false);
      }

      // Verify user is a supplier
      final userDoc =
          await _firestore.collection('suppliers').doc(currentUser.uid).get();

      return Right(userDoc.exists);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('No authenticated user'));
      }
      return Right(currentUser.uid);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
