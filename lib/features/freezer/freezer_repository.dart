import 'package:isar/isar.dart';
import '../../models/freezer.dart';

class FreezerRepository {
  final Isar _isar;

  FreezerRepository(this._isar);

  Future<List<Freezer>> getAllFreezers() async {
    return _isar.freezers.where().findAll();
  }

  Future<void> addFreezer(Freezer freezer) async {
    await _isar.writeTxn(() => _isar.freezers.put(freezer));
  }

  Future<void> updateFreezer(Freezer freezer) async {
    await _isar.writeTxn(() => _isar.freezers.put(freezer));
  }

  Future<void> deleteFreezer(int id) async {
    await _isar.writeTxn(() => _isar.freezers.delete(id));
  }
}
