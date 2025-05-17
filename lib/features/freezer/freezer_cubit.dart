import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/freezer.dart';
import 'freezer_repository.dart';

part 'freezer_state.dart';

class FreezerCubit extends Cubit<FreezerState> {
  final FreezerRepository repository;

  FreezerCubit(this.repository) : super(FreezerInitial());

  Future<void> loadFreezers() async {
    emit(FreezerLoading());
    final freezers = await repository.getAllFreezers();
    emit(FreezerLoaded(freezers));
  }

  Future<void> addFreezer(Freezer freezer) async {
    await repository.addFreezer(freezer);
    await loadFreezers();
  }

  Future<void> updateFreezer(Freezer freezer) async {
    await repository.updateFreezer(freezer);
    await loadFreezers();
  }

  Future<void> deleteFreezer(int id) async {
    await repository.deleteFreezer(id);
    await loadFreezers();
  }
}
