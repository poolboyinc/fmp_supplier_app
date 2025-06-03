import 'package:dartz/dartz.dart';
import 'package:fmp_supplier_app/core/errors/failures.dart';
import 'package:fmp_supplier_app/features/parties/domain/entities/party_entity.dart';

abstract class PartyRepository {
  Future<Either<Failure, List<PartyEntity>>> getOwnerParties(String ownerId);
  Future<Either<Failure, PartyEntity>> getParty(String partyId);
  Future<Either<Failure, String>> createParty(PartyEntity party);
  Future<Either<Failure, void>> updateParty(PartyEntity party);
  Future<Either<Failure, void>> deleteParty(String partyId);
  Future<Either<Failure, String>> uploadPartyImage(
    String filePath,
    String fileName,
  );
  Future<Either<Failure, String>> uploadPartyLogo(
    String filePath,
    String fileName,
  );
}
