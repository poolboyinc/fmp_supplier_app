import 'package:equatable/equatable.dart';
import 'package:fmp_supplier_app/features/parties/domain/entities/party_entity.dart';

abstract class PartyEvent extends Equatable {
  const PartyEvent();

  @override
  List<Object?> get props => [];
}

class GetOwnerPartiesEvent extends PartyEvent {
  final String ownerId;

  const GetOwnerPartiesEvent(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class GetPartyEvent extends PartyEvent {
  final String partyId;

  const GetPartyEvent(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class CreatePartyEvent extends PartyEvent {
  final PartyEntity party;

  const CreatePartyEvent(this.party);

  @override
  List<Object?> get props => [party];
}

class UpdatePartyEvent extends PartyEvent {
  final PartyEntity party;

  const UpdatePartyEvent(this.party);

  @override
  List<Object?> get props => [party];
}

class DeletePartyEvent extends PartyEvent {
  final String partyId;

  const DeletePartyEvent(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class UploadPartyImageEvent extends PartyEvent {
  final String filePath;
  final String fileName;

  const UploadPartyImageEvent(this.filePath, this.fileName);

  @override
  List<Object?> get props => [filePath, fileName];
}

class UploadPartyLogoEvent extends PartyEvent {
  final String filePath;
  final String fileName;

  const UploadPartyLogoEvent(this.filePath, this.fileName);

  @override
  List<Object?> get props => [filePath, fileName];
}
