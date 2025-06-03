import 'package:equatable/equatable.dart';
import 'package:fmp_supplier_app/features/parties/domain/entities/party_entity.dart';

abstract class PartyState extends Equatable {
  const PartyState();

  @override
  List<Object?> get props => [];
}

class PartyInitial extends PartyState {}

class PartyLoading extends PartyState {}

class PartiesLoaded extends PartyState {
  final List<PartyEntity> parties;

  const PartiesLoaded(this.parties);

  @override
  List<Object?> get props => [parties];
}

class PartyLoaded extends PartyState {
  final PartyEntity party;

  const PartyLoaded(this.party);

  @override
  List<Object?> get props => [party];
}

class PartyCreated extends PartyState {
  final String partyId;

  const PartyCreated(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class PartyUpdated extends PartyState {}

class PartyDeleted extends PartyState {}

class PartyError extends PartyState {
  final String message;

  const PartyError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImageUploaded extends PartyState {
  final String imageUrl;
  final bool isLogo;

  const ImageUploaded(this.imageUrl, {this.isLogo = false});

  @override
  List<Object?> get props => [imageUrl, isLogo];
}
