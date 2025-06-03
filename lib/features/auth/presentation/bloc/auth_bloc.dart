import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fmp_supplier_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final isSignedInResult = await authRepository.isSignedIn();

    // Await the fold operation that contains async code
    await isSignedInResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (isSignedIn) async {
        if (isSignedIn) {
          final userIdResult = await authRepository.getCurrentUserId();

          userIdResult.fold(
            (failure) => emit(AuthError(failure.message)),
            (userId) => emit(Authenticated(userId)),
          );
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await authRepository.signIn(event.email, event.password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (userId) => emit(Authenticated(userId)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
}
