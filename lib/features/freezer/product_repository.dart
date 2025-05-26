import 'package:isar/isar.dart';
import 'package:my_freezer/models/product.dart';
import 'package:my_freezer/models/freezer.dart';
import 'package:logger/logger.dart';

class ProductRepository {
  final Isar _isar;
  final _logger = Logger();

  ProductRepository(this._isar);

  Future<List<Product>> getAllProducts() async {
    return await _isar.products.where().findAll();
  }

  Future<Product> getProduct(int productId) async {
    final product = await _isar.products.get(productId);
    if (product == null) {
      throw Exception('Product not found');
    }
    return product;
  }

  Future<Product> addProduct(Product product) async {
    _logger.i(
        'Adding product ${product.name} to freezer ${product.freezer.value?.id}');
    await _isar.writeTxn(() async {
      await _isar.products.put(product);
      if (product.freezer.value != null) {
        _logger.i('Saving freezer link for product ${product.name}');
        await product.freezer.save();
      } else {
        _logger.e('Product freezer link is not set for ${product.name}');
      }
    });
    _logger.i('Product ${product.name} added successfully');
    return product;
  }

  Future<Product> updateProduct(Product product) async {
    await _isar.writeTxn(() async {
      await _isar.products.put(product);
      if (product.freezer.value != null) {
        await product.freezer.save();
      }
    });
    return product;
  }

  Future<void> deleteProduct(int productId) async {
    await _isar.writeTxn(() async {
      await _isar.products.delete(productId);
    });
  }

  Future<List<Product>> getExpiringProducts() async {
    return _isar.products.filter().isExpiringSoonEqualTo(true).findAll();
  }

  Future<List<Product>> getExpiredProducts() async {
    return _isar.products.filter().isExpiredEqualTo(true).findAll();
  }

  Future<List<Product>> getProductsByFreezerId(int freezerId) async {
    _logger.i('Getting products for freezer $freezerId');
    final freezer = await _isar.freezers.get(freezerId);
    if (freezer == null) {
      _logger.e('Freezer not found with id: $freezerId');
      throw Exception('Freezer not found');
    }
    final products = await freezer.products.filter().findAll();
    _logger.i('Found ${products.length} products for freezer $freezerId');
    return products;
  }
}
