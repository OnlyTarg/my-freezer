import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'product.dart';

part 'freezer.g.dart';

@collection
class Freezer {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String uuid;

  String name;
  String? description;

  @Backlink(to: 'freezer')
  final products = IsarLinks<Product>();

  DateTime? createdAt;
  DateTime? updatedAt;

  Freezer({
    required this.uuid,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Freezer.create({
    required String name,
    String? description,
  }) {
    final now = DateTime.now();
    return Freezer(
      uuid: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  Freezer copyWith({
    String? name,
    String? description,
  }) {
    return Freezer(
      uuid: uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
