import 'package:isar/isar.dart';
import 'package:my_freezer/models/product.dart';

class ProductRepository {
  final Isar _isar;

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
    await _isar.writeTxn(() async {
      await _isar.products.put(product);
    });
    return product;
  }

  Future<Product> updateProduct(Product product) async {
    await _isar.writeTxn(() async {
      await _isar.products.put(product);
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
}
