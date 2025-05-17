import 'package:isar/isar.dart';
import 'freezer.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String name;

  String? description;

  @Enumerated(EnumType.name)
  ProductCategory category;

  DateTime dateAdded;

  int shelfLifeInDays;

  String? imagePath;

  final freezer = IsarLink<Freezer>();

  Product({
    required this.name,
    this.description,
    required this.category,
    required this.dateAdded,
    required this.shelfLifeInDays,
    this.imagePath,
  });

  factory Product.create({
    required String name,
    String? description,
    required ProductCategory category,
    required DateTime dateAdded,
    required int shelfLifeInDays,
    String? imagePath,
  }) {
    return Product(
      name: name,
      description: description,
      category: category,
      dateAdded: dateAdded,
      shelfLifeInDays: shelfLifeInDays,
      imagePath: imagePath,
    );
  }

  Product copyWith({
    String? name,
    String? description,
    ProductCategory? category,
    DateTime? dateAdded,
    int? shelfLifeInDays,
    String? imagePath,
  }) {
    return Product(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      dateAdded: dateAdded ?? this.dateAdded,
      shelfLifeInDays: shelfLifeInDays ?? this.shelfLifeInDays,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  int? get recommendedShelfLifeDays => shelfLifeInDays;
  String? get photoPath => imagePath;

  int get daysUntilExpiry {
    final expiryDate = dateAdded.add(Duration(days: shelfLifeInDays));
    return expiryDate.difference(DateTime.now()).inDays;
  }

  bool get isExpired => daysUntilExpiry < 0;

  bool get isExpiringSoon => daysUntilExpiry >= 0 && daysUntilExpiry <= 3;
}

enum ProductCategory {
  meat,
  fish,
  vegetables,
  fruits,
  dairy,
  prepared,
  other,
}
