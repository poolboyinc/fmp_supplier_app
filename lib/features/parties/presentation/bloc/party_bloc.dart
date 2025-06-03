import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fmp_supplier_app/features/parties/domain/repositories/party_repository.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_event.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_state.dart';

class PartyBloc extends Bloc<PartyEvent, PartyState> {
  final PartyRepository partyRepository;

  PartyBloc({required this.partyRepository}) : super(PartyInitial()) {
    on<GetOwnerPartiesEvent>(_onGetOwnerParties);
    on<GetPartyEvent>(_onGetParty);
    on<CreatePartyEvent>(_onCreateParty);
    on<UpdatePartyEvent>(_onUpdateParty);
    on<DeletePartyEvent>(_onDeleteParty);
    on<UploadPartyImageEvent>(_onUploadPartyImage);
    on<UploadPartyLogoEvent>(_onUploadPartyLogo);
  }

  Future<void> _onGetOwnerParties(
    GetOwnerPartiesEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.getOwnerParties(event.ownerId);

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (parties) => emit(PartiesLoaded(parties)),
    );
  }

  Future<void> _onGetParty(
    GetPartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.getParty(event.partyId);

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (party) => emit(PartyLoaded(party)),
    );
  }

  Future<void> _onCreateParty(
    CreatePartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.createParty(event.party);

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (partyId) => emit(PartyCreated(partyId)),
    );
  }

  Future<void> _onUpdateParty(
    UpdatePartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.updateParty(event.party);

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (_) => emit(PartyUpdated()),
    );
  }

  Future<void> _onDeleteParty(
    DeletePartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.deleteParty(event.partyId);

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (_) => emit(PartyDeleted()),
    );
  }

  Future<void> _onUploadPartyImage(
    UploadPartyImageEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.uploadPartyImage(
      event.filePath,
      event.fileName,
    );

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (imageUrl) => emit(ImageUploaded(imageUrl)),
    );
  }

  Future<void> _onUploadPartyLogo(
    UploadPartyLogoEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(PartyLoading());

    final result = await partyRepository.uploadPartyLogo(
      event.filePath,
      event.fileName,
    );

    result.fold(
      (failure) => emit(PartyError(failure.message)),
      (imageUrl) => emit(ImageUploaded(imageUrl, isLogo: true)),
    );
  }
}
