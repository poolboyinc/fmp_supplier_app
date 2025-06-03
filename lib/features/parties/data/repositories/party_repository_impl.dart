import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fmp_supplier_app/core/errors/failures.dart';
import 'package:fmp_supplier_app/features/parties/data/models/party_model.dart';
import 'package:fmp_supplier_app/features/parties/domain/entities/party_entity.dart';
import 'package:fmp_supplier_app/features/parties/domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PartyRepositoryImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, List<PartyEntity>>> getOwnerParties(
    String ownerId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('parties')
              .where('ownerId', isEqualTo: ownerId)
              .get();

      final parties =
          querySnapshot.docs
              .map((doc) => PartyModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();

      return Right(parties);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PartyEntity>> getParty(String partyId) async {
    try {
      final docSnapshot =
          await _firestore.collection('parties').doc(partyId).get();

      if (!docSnapshot.exists) {
        return Left(ServerFailure('Party not found'));
      }

      final party = PartyModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
      });

      return Right(party);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createParty(PartyEntity party) async {
    try {
      final partyModel = party as PartyModel;
      final docRef = await _firestore
          .collection('parties')
          .add(partyModel.toJson());

      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateParty(PartyEntity party) async {
    try {
      final partyModel = party as PartyModel;
      await _firestore
          .collection('parties')
          .doc(party.id)
          .update(partyModel.toJson());

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteParty(String partyId) async {
    try {
      await _firestore.collection('parties').doc(partyId).delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPartyImage(
    String filePath,
    String fileName,
  ) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('party_images/$fileName');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPartyLogo(
    String filePath,
    String fileName,
  ) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('party_logos/$fileName');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
