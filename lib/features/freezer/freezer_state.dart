part of 'freezer_cubit.dart';

abstract class FreezerState extends Equatable {
  const FreezerState();

  @override
  List<Object?> get props => [];
}

class FreezerInitial extends FreezerState {}

class FreezerLoading extends FreezerState {}

class FreezerLoaded extends FreezerState {
  final List<Freezer> freezers;
  const FreezerLoaded(this.freezers);

  @override
  List<Object?> get props => [freezers];
}

class FreezerError extends FreezerState {
  final String message;
  const FreezerError(this.message);

  @override
  List<Object?> get props => [message];
}
