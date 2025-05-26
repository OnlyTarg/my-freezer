import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_freezer/features/freezer/product_repository.dart';
import 'package:my_freezer/models/product.dart';

part 'product_cubit.freezed.dart';

@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.loaded(List<Product> products) = _Loaded;
  const factory ProductState.error(String message) = _Error;
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(const ProductState.initial());

  Future<void> loadProducts(int freezerId) async {
    emit(const ProductState.loading());
    try {
      final products = await _repository.getProductsByFreezerId(freezerId);
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> addProduct(Product product) async {
    emit(const ProductState.loading());
    try {
      final savedProduct = await _repository.addProduct(product);
      if (savedProduct.freezer.value == null) {
        throw Exception('Product freezer link is not set');
      }
      final products = await _repository
          .getProductsByFreezerId(savedProduct.freezer.value!.id);
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> updateProduct(Product product) async {
    emit(const ProductState.loading());
    try {
      final savedProduct = await _repository.updateProduct(product);
      if (savedProduct.freezer.value == null) {
        throw Exception('Product freezer link is not set');
      }
      final products = await _repository
          .getProductsByFreezerId(savedProduct.freezer.value!.id);
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> deleteProduct(int productId, int freezerId) async {
    emit(const ProductState.loading());
    try {
      await _repository.deleteProduct(productId);
      final products = await _repository.getProductsByFreezerId(freezerId);
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> loadProduct(int productId) async {
    emit(const ProductState.loading());
    try {
      final product = await _repository.getProduct(productId);
      emit(ProductState.loaded([product]));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }
}
