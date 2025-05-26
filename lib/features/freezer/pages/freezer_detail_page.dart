import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:logger/logger.dart';
import '../../../models/freezer.dart';
import '../../../models/product.dart';
import '../../../core/di/service_locator.dart';
import '../product_cubit.dart';
import '../product_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ProductSortOption {
  nameAsc,
  nameDesc,
  dateAddedAsc,
  dateAddedDesc,
  expiryAsc,
  expiryDesc,
}

@RoutePage()
class FreezerDetailPage extends StatefulWidget {
  const FreezerDetailPage({
    @PathParam('freezerId') required this.freezerId,
    super.key,
  });

  final int freezerId;

  @override
  State<FreezerDetailPage> createState() => _FreezerDetailPageState();
}

class _FreezerDetailPageState extends State<FreezerDetailPage> {
  final _logger = Logger();
  ProductSortOption _sortOption = ProductSortOption.dateAddedDesc;
  ProductCategory? _selectedCategory;
  String _searchQuery = '';
  bool _showExpiredOnly = false;
  bool _showExpiringSoonOnly = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductCubit(sl<ProductRepository>())..loadProducts(widget.freezerId),
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          final cubit = context.read<ProductCubit>();
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[50]!,
                  Colors.blue[100]!,
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                slivers: [
                  _buildAppBar(context, state, cubit),
                  if (state.maybeWhen(
                    loaded: (products) => products.isNotEmpty,
                    orElse: () => false,
                  ))
                    _buildFilterBar(context),
                  if (state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ))
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.maybeWhen(
                    loaded: (products) => true,
                    orElse: () => false,
                  ))
                    _buildProductList(context, state, cubit)
                  else if (state.maybeWhen(
                    error: (message) => true,
                    orElse: () => false,
                  ))
                    SliverFillRemaining(
                      child: Center(
                          child: Text('Error: ${state.maybeWhen(
                        error: (message) => message,
                        orElse: () => 'Unknown error',
                      )}')),
                    ),
                ],
              ),
              floatingActionButton: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[300]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => _showAddProductDialog(context, cubit),
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addProduct),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, ProductState state, ProductCubit cubit) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[100]!.withOpacity(0.9),
              Colors.blue[50]!.withOpacity(0.9),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 45, bottom: 8),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.maybeWhen(
                loaded: (products) => products.isNotEmpty,
                orElse: () => false,
              )) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.ac_unit, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${state.maybeWhen(loaded: (products) => products.length, orElse: () => 0)} ${AppLocalizations.of(context)!.products}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (state.maybeWhen(
                      loaded: (products) => products.any((p) => p.isExpired),
                      orElse: () => false,
                    ))
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning,
                                size: 14, color: Colors.red[700]),
                            const SizedBox(width: 4),
                            Text(
                              '${state.maybeWhen(loaded: (products) => products.where((p) => p.isExpired).length, orElse: () => 0)} ${AppLocalizations.of(context)!.expired}',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.maybeWhen(
                      loaded: (products) =>
                          products.any((p) => p.isExpiringSoon),
                      orElse: () => false,
                    )) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 14, color: Colors.orange[700]),
                            const SizedBox(width: 4),
                            Text(
                              '${state.maybeWhen(loaded: (products) => products.where((p) => p.isExpiringSoon).length, orElse: () => 0)} ${AppLocalizations.of(context)!.expiringSoon}',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.sort, color: Colors.blue[700]),
          onPressed: () => _showSortDialog(context),
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: Colors.blue[700]),
          onPressed: () => _showFilterDialog(context),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue[100]!.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchProducts,
                  prefixIcon:
                      Icon(Icons.search, size: 20, color: Colors.blue[300]),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            if (_selectedCategory != null ||
                _showExpiredOnly ||
                _showExpiringSoonOnly)
              IconButton(
                icon: Icon(Icons.clear_all, color: Colors.blue[300]),
                onPressed: () => setState(() {
                  _selectedCategory = null;
                  _showExpiredOnly = false;
                  _showExpiringSoonOnly = false;
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(
      BuildContext context, ProductState state, ProductCubit cubit) {
    return state.maybeWhen(
      loaded: (products) {
        var filteredProducts = products.where((product) {
          if (_searchQuery.isNotEmpty &&
              !product.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) &&
              !(product.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)) {
            return false;
          }
          if (_selectedCategory != null &&
              product.category != _selectedCategory) {
            return false;
          }
          if (_showExpiredOnly && !product.isExpired) {
            return false;
          }
          if (_showExpiringSoonOnly && !product.isExpiringSoon) {
            return false;
          }
          return true;
        }).toList();

        filteredProducts.sort((a, b) {
          switch (_sortOption) {
            case ProductSortOption.nameAsc:
              return a.name.compareTo(b.name);
            case ProductSortOption.nameDesc:
              return b.name.compareTo(a.name);
            case ProductSortOption.dateAddedAsc:
              return (a.dateAdded).compareTo(b.dateAdded);
            case ProductSortOption.dateAddedDesc:
              return (b.dateAdded).compareTo(a.dateAdded);
            case ProductSortOption.expiryAsc:
              return (a.recommendedShelfLifeDays ?? 0)
                  .compareTo(b.recommendedShelfLifeDays ?? 0);
            case ProductSortOption.expiryDesc:
              return (b.recommendedShelfLifeDays ?? 0)
                  .compareTo(a.recommendedShelfLifeDays ?? 0);
          }
        });

        if (filteredProducts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(AppLocalizations.of(context)!.noProductsFound),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = filteredProducts[index];
                return Dismissible(
                  key: Key(product.id.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    final l10n = AppLocalizations.of(context)!;
                    return await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(l10n.deleteProduct),
                              content:
                                  Text(l10n.deleteProductConfirm(product.name)),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                  },
                  onDismissed: (direction) {
                    cubit.deleteProduct(product.id, widget.freezerId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} deleted'),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)!.undo,
                          onPressed: () {
                            // TODO: Implement undo functionality
                          },
                        ),
                      ),
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue[100]!.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue[100]!),
                      ),
                      child: InkWell(
                        onTap: () =>
                            _showEditProductDialog(context, product, cubit),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.photoPath != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Stack(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.file(
                                        File(product.photoPath!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          color: _getCategoryColor(
                                              product.category),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.blue[50]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                  bottom: const Radius.circular(12),
                                  top: product.photoPath == null
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                      if (product.isExpired ||
                                          product.isExpiringSoon)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product.isExpired
                                                ? Colors.red[50]
                                                : Colors.orange[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: product.isExpired
                                                  ? Colors.red[200]!
                                                  : Colors.orange[200]!,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                product.isExpired
                                                    ? Icons.warning
                                                    : Icons.timer_outlined,
                                                size: 12,
                                                color: product.isExpired
                                                    ? Colors.red[700]
                                                    : Colors.orange[700],
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                product.isExpired
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .expired
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .expiringSoon,
                                                style: TextStyle(
                                                  color: product.isExpired
                                                      ? Colors.red[700]
                                                      : Colors.orange[700],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (product.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      product.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      _buildInfoChip(
                                        icon: Icons.calendar_today,
                                        label:
                                            '${AppLocalizations.of(context)!.dateAdded}: ${product.dateAdded.toString().split(' ')[0]}',
                                        color: Colors.blue[700]!,
                                      ),
                                      if (product.recommendedShelfLifeDays !=
                                          null)
                                        _buildInfoChip(
                                          icon: Icons.timer,
                                          label:
                                              '${product.recommendedShelfLifeDays} ${AppLocalizations.of(context)!.days}',
                                          color: Colors.blue[700]!,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredProducts.length,
            ),
          ),
        );
      },
      orElse: () => Container(),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.meat:
        return Icons.restaurant;
      case ProductCategory.fish:
        return Icons.set_meal;
      case ProductCategory.vegetables:
        return Icons.eco;
      case ProductCategory.fruits:
        return Icons.apple;
      case ProductCategory.dairy:
        return Icons.water_drop;
      case ProductCategory.other:
        return Icons.cake;
      case ProductCategory.prepared:
        return Icons.lunch_dining;
    }
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.meat:
        return Colors.red;
      case ProductCategory.fish:
        return Colors.blue;
      case ProductCategory.vegetables:
        return Colors.green;
      case ProductCategory.fruits:
        return Colors.orange;
      case ProductCategory.dairy:
        return Colors.lightBlue;
      case ProductCategory.other:
        return Colors.purple;
      case ProductCategory.prepared:
        return Colors.brown;
    }
  }

  void _showSortDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sortProducts),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProductSortOption.values.map((option) {
            return RadioListTile<ProductSortOption>(
              title: Text(_getSortOptionLabel(option, context)),
              value: option,
              groupValue: _sortOption,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOption = value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getSortOptionLabel(ProductSortOption option, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (option) {
      case ProductSortOption.nameAsc:
        return l10n.sortByNameAsc;
      case ProductSortOption.nameDesc:
        return l10n.sortByNameDesc;
      case ProductSortOption.dateAddedAsc:
        return l10n.sortByDateAddedAsc;
      case ProductSortOption.dateAddedDesc:
        return l10n.sortByDateAddedDesc;
      case ProductSortOption.expiryAsc:
        return l10n.sortByExpiryAsc;
      case ProductSortOption.expiryDesc:
        return l10n.sortByExpiryDesc;
    }
  }

  void _showFilterDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filterProducts),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.category,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(l10n.all),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = null);
                    Navigator.of(context).pop();
                  },
                ),
                ...ProductCategory.values.map((category) {
                  return FilterChip(
                    label: Text(category.name.toUpperCase()),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(
                          () => _selectedCategory = selected ? category : null);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.status,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.expired),
                  selected: _showExpiredOnly,
                  onSelected: (selected) {
                    setState(() => _showExpiredOnly = selected);
                    Navigator.of(context).pop();
                  },
                ),
                FilterChip(
                  label: Text(AppLocalizations.of(context)!.expiringSoon),
                  selected: _showExpiringSoonOnly,
                  onSelected: (selected) {
                    setState(() => _showExpiringSoonOnly = selected);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickAndSaveImage(
      BuildContext context, ImageSource source) async {
    try {
      _logger.i('Starting image picker with source: $source');
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        _logger.i('No image selected');
        return null;
      }

      _logger.i('Image picked successfully: ${image.path}');
      _logger.i(
          'Image details - size: ${await File(image.path).length()}, name: ${path.basename(image.path)}');

      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = File('${directory.path}/$fileName');

        _logger.i('Saving image to: ${savedImage.path}');
        await File(image.path).copy(savedImage.path);
        _logger.i(
            'Image saved successfully. File exists: ${await savedImage.exists()}, size: ${await savedImage.length()}');

        return savedImage.path;
      } catch (e, stackTrace) {
        _logger.e('Error saving image', error: e, stackTrace: stackTrace);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .errorSavingImage(e.toString()))),
          );
        }
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Error picking image', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorPickingImage(e.toString()))),
        );
      }
      return null;
    }
  }

  void _showAddProductDialog(BuildContext context, ProductCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final shelfLifeController = TextEditingController();
    ProductCategory selectedCategory = ProductCategory.other;
    DateTime? selectedDate;
    String? photoPath;
    bool isNameError = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.ac_unit, size: 24, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.addProduct,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (photoPath != null)
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: double.infinity,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue[100]!.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(photoPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      _logger.e('Error loading image',
                                          error: error, stackTrace: stackTrace);
                                      return Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.error_outline,
                                            size: 50, color: Colors.blue[700]),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final path = await _pickAndSaveImage(
                                          context, ImageSource.camera);
                                      if (path != null) {
                                        setState(() => photoPath = path);
                                      }
                                    },
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.blue[700]),
                                    label: Text(l10n.camera),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[50],
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                            color: Colors.blue[200]!),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final path = await _pickAndSaveImage(
                                          context, ImageSource.gallery);
                                      if (path != null) {
                                        setState(() => photoPath = path);
                                      }
                                    },
                                    icon: Icon(Icons.photo_library,
                                        color: Colors.blue[700]),
                                    label: Text(l10n.gallery),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[50],
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                            color: Colors.blue[200]!),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: l10n.name,
                                prefixIcon: const Icon(Icons.label),
                                errorText:
                                    isNameError ? l10n.nameRequired : null,
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              onChanged: (value) {
                                if (isNameError && value.trim().isNotEmpty) {
                                  setState(() => isNameError = false);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descController,
                              decoration: InputDecoration(
                                labelText: l10n.description,
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ProductCategory>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: l10n.category,
                                prefixIcon: const Icon(Icons.category),
                              ),
                              items: ProductCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(_getCategoryIcon(category),
                                          color: _getCategoryColor(category),
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(category.name.toUpperCase()),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedCategory = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: shelfLifeController,
                              decoration: InputDecoration(
                                labelText: l10n.recommendedShelfLife,
                                prefixIcon: const Icon(Icons.timer),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.calendar_today,
                                  color: Colors.blue[300]),
                              title: Text(
                                selectedDate != null
                                    ? '${l10n.dateAdded}: ${selectedDate.toString().split(' ')[0]}'
                                    : l10n.selectDateAdded,
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.calendar_month,
                                    color: Colors.blue[700]),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() => selectedDate = date);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final desc = descController.text.trim();
                            final shelfLife =
                                int.tryParse(shelfLifeController.text.trim());

                            if (name.isEmpty) {
                              setState(() => isNameError = true);
                              return;
                            }

                            _logger.i(
                                'Creating new product with photo path: $photoPath');
                            if (photoPath != null) {
                              _logger.i(
                                  'Photo file exists: ${await File(photoPath!).exists()}');
                            }

                            final product = Product.create(
                              name: name,
                              description: desc.isEmpty ? null : desc,
                              category: selectedCategory,
                              dateAdded: selectedDate ?? DateTime.now(),
                              shelfLifeInDays: shelfLife ?? 0,
                              imagePath: photoPath,
                            );

                            final freezer = await GetIt.I<Isar>()
                                .freezers
                                .get(widget.freezerId);
                            if (freezer != null) {
                              _logger
                                  .i('Adding product to freezer ${freezer.id}');
                              product.freezer.value = freezer;
                              await cubit.addProduct(product);
                              _logger.i('Product added successfully');
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              _logger.e(
                                  'Freezer not found with id: ${widget.freezerId}');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .freezerNotFound)),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(
      BuildContext context, Product product, ProductCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: product.name);
    final descController =
        TextEditingController(text: product.description ?? '');
    final shelfLifeController = TextEditingController(
      text: product.recommendedShelfLifeDays?.toString() ?? '',
    );
    ProductCategory selectedCategory = product.category;
    DateTime? selectedDate = product.dateAdded;
    String? photoPath = product.imagePath;
    bool isNameError = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.editProduct,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (photoPath != null)
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                maxWidth: double.infinity,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(photoPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    _logger.e('Error loading image',
                                        error: error, stackTrace: stackTrace);
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.error_outline,
                                            size: 50, color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final path = await _pickAndSaveImage(
                                      context, ImageSource.camera);
                                  if (path != null) {
                                    setState(() => photoPath = path);
                                  }
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: Text(l10n.camera),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final path = await _pickAndSaveImage(
                                      context, ImageSource.gallery);
                                  if (path != null) {
                                    setState(() => photoPath = path);
                                  }
                                },
                                icon: const Icon(Icons.photo_library),
                                label: Text(l10n.gallery),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: l10n.name,
                              prefixIcon: const Icon(Icons.label),
                              errorText: isNameError ? l10n.nameRequired : null,
                              errorStyle: const TextStyle(color: Colors.red),
                            ),
                            onChanged: (value) {
                              if (isNameError && value.trim().isNotEmpty) {
                                setState(() => isNameError = false);
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descController,
                            decoration: InputDecoration(
                              labelText: l10n.description,
                              prefixIcon: const Icon(Icons.description),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ProductCategory>(
                            value: selectedCategory,
                            decoration: InputDecoration(
                              labelText: l10n.category,
                              prefixIcon: const Icon(Icons.category),
                            ),
                            items: ProductCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedCategory = value);
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: shelfLifeController,
                            decoration: InputDecoration(
                              labelText: l10n.recommendedShelfLife,
                              prefixIcon: const Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(selectedDate == null
                                ? l10n.selectDateAdded
                                : '${l10n.dateAdded}: ${selectedDate.toString().split(' ')[0]}'),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => selectedDate = date);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final desc = descController.text.trim();
                          final shelfLife =
                              int.tryParse(shelfLifeController.text.trim());

                          if (name.isEmpty) {
                            setState(() => isNameError = true);
                            return;
                          }

                          _logger.i(
                              'Updating product with photo path: $photoPath');
                          if (photoPath != null) {
                            _logger.i(
                                'Photo file exists: ${await File(photoPath!).exists()}');
                          }

                          final updatedProduct = product.copyWith(
                            name: name,
                            description: desc.isEmpty ? null : desc,
                            category: selectedCategory,
                            dateAdded: selectedDate ?? DateTime.now(),
                            shelfLifeInDays: shelfLife ?? 0,
                            imagePath: photoPath,
                          );

                          _logger.i('Updating product ${updatedProduct.id}');
                          await cubit.updateProduct(updatedProduct);
                          _logger.i('Product updated successfully');
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
