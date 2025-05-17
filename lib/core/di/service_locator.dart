import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/freezer.dart';
import '../../models/product.dart';
import '../../features/freezer/freezer_repository.dart';
import '../../features/freezer/product_repository.dart';
import '../services/locale_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Register LocaleService
  sl.registerSingleton<LocaleService>(LocaleService(prefs));

  // Register Isar database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [FreezerSchema, ProductSchema],
    directory: dir.path,
  );
  sl.registerSingleton<Isar>(isar);

  // Register repositories
  sl.registerLazySingleton<FreezerRepository>(
      () => FreezerRepository(sl<Isar>()));
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepository(sl<Isar>()));

  // Register other services, repositories, blocs here as needed
}
