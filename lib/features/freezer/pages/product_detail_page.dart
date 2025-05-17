import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_freezer/models/product.dart';
import '../../../core/di/service_locator.dart';
import '../product_cubit.dart';

@RoutePage()
class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    @PathParam('productId') required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => ProductCubit(sl())..loadProduct(productId),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.inventory_2,
                  size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.productDetails,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (products) => Row(
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.edit, color: theme.colorScheme.primary),
                        onPressed: () =>
                            _showEditProductDialog(context, products[0]),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.delete, color: theme.colorScheme.error),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, products[0]),
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
        body: Container(
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
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const Center(child: CircularProgressIndicator()),
                loaded: (products) {
                  final product = products[0];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.imagePath!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue[100]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                if (product.description != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    product.description!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  context,
                                  Icons.category,
                                  l10n.category,
                                  product.category.name,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.calendar_today,
                                  l10n.dateAdded,
                                  DateFormat.yMMMd().format(product.dateAdded),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.timer,
                                  l10n.recommendedShelfLife,
                                  '${product.shelfLifeInDays} ${l10n.days}',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.warning,
                                  l10n.status,
                                  _getStatusText(product, context),
                                  valueColor: _getStatusColor(product),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (message) => Center(child: Text('Error: $message')),
                orElse: () =>
                    const Center(child: Text('Error loading product')),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value,
      {Color? valueColor}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusText(Product product, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysLeft = product.daysUntilExpiry;
    if (daysLeft < 0) {
      return l10n.expiredDaysAgo(-daysLeft);
    } else if (daysLeft == 0) {
      return l10n.expiresToday;
    } else if (daysLeft <= 3) {
      return l10n.expiresInDays(daysLeft);
    } else {
      return l10n.goodForDays(daysLeft);
    }
  }

  Color _getStatusColor(Product product) {
    final daysLeft = product.daysUntilExpiry;
    if (daysLeft < 0) {
      return Colors.red;
    } else if (daysLeft <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: product.name);
    final shelfLifeController = TextEditingController(
      text: product.shelfLifeInDays.toString(),
    );
    DateTime? selectedDate = product.dateAdded;
    bool isNameError = false;
    bool isShelfLifeError = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit,
                        size: 24, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.editProduct,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    prefixIcon:
                        Icon(Icons.label, color: theme.colorScheme.primary),
                    errorText: isNameError ? l10n.nameRequired : null,
                    errorStyle: TextStyle(color: theme.colorScheme.error),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (isNameError && value.trim().isNotEmpty) {
                      setState(() => isNameError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: shelfLifeController,
                  decoration: InputDecoration(
                    labelText: l10n.recommendedShelfLife,
                    prefixIcon: Icon(Icons.calendar_today,
                        color: theme.colorScheme.primary),
                    errorText: isShelfLifeError ? l10n.nameRequired : null,
                    errorStyle: TextStyle(color: theme.colorScheme.error),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (isShelfLifeError && value.trim().isNotEmpty) {
                      setState(() => isShelfLifeError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
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
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.selectDateAdded,
                      prefixIcon: Icon(Icons.calendar_month,
                          color: theme.colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat.yMMMd().format(selectedDate!)
                          : l10n.selectDateAdded,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          setState(() => isNameError = true);
                          return;
                        }
                        if (int.tryParse(shelfLifeController.text.trim()) ==
                                null ||
                            int.tryParse(shelfLifeController.text.trim())! <=
                                0) {
                          setState(() => isShelfLifeError = true);
                          return;
                        }
                        // TODO: Implement product update with name, shelfLife, and selectedDate
                        Navigator.of(context).pop();
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
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.errorContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.deleteProduct,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deleteProductConfirm(product.name),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Delete product logic here
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
