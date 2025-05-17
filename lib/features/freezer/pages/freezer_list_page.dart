import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/freezer.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/config/app_router.dart';
import '../freezer_cubit.dart';
import '../freezer_repository.dart';

@RoutePage()
class FreezerListPage extends StatelessWidget {
  const FreezerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => FreezerCubit(sl<FreezerRepository>())..loadFreezers(),
      child: BlocBuilder<FreezerCubit, FreezerState>(
        builder: (context, state) {
          final cubit = context.read<FreezerCubit>();
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Row(
                  children: [
                    Icon(Icons.kitchen,
                        size: 24, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.myFreezers,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon:
                        Icon(Icons.settings, color: theme.colorScheme.primary),
                    onPressed: () => context.router.push(const SettingsRoute()),
                  ),
                ],
              ),
              body: _buildBody(context, state),
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
                child: FloatingActionButton(
                  onPressed: () => _showAddFreezerDialog(context, cubit),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FreezerState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (state is FreezerLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FreezerLoaded) {
      if (state.freezers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ac_unit, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n.noFreezersYet,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addFirstFreezer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }
      final cubit = context.read<FreezerCubit>();
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.freezers.length,
        itemBuilder: (context, index) {
          final freezer = state.freezers[index];
          return Container(
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
                onTap: () => context.router.push(
                  FreezerDetailRoute(freezerId: freezer.id),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.blue[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.ac_unit,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  freezer.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                if (freezer.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    freezer.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon:
                                Icon(Icons.more_vert, color: Colors.blue[700]),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit,
                                        size: 20, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 20, color: Colors.red[700]),
                                    const SizedBox(width: 8),
                                    const Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditFreezerDialog(context, freezer, cubit);
                              } else if (value == 'delete') {
                                _showDeleteConfirmationDialog(
                                    context, freezer, cubit);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else if (state is FreezerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              l10n.error(state.message),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showAddFreezerDialog(BuildContext context, FreezerCubit cubit) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isNameError = false;

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
                    Icon(Icons.ac_unit,
                        size: 24, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.addFreezer,
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
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: Icon(Icons.description,
                        color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
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
                        final desc = descController.text.trim();
                        if (name.isEmpty) {
                          setState(() => isNameError = true);
                          return;
                        }
                        cubit.addFreezer(
                          Freezer.create(
                            name: name,
                            description: desc.isEmpty ? null : desc,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.add),
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

  void _showEditFreezerDialog(
      BuildContext context, Freezer freezer, FreezerCubit cubit) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: freezer.name);
    final descController =
        TextEditingController(text: freezer.description ?? '');
    bool isNameError = false;

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
                    Icon(Icons.ac_unit,
                        size: 24, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.editFreezer,
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
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: Icon(Icons.description,
                        color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
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
                        final desc = descController.text.trim();
                        if (name.isEmpty) {
                          setState(() => isNameError = true);
                          return;
                        }
                        cubit.updateFreezer(
                          freezer.copyWith(
                            name: name,
                            description: desc.isEmpty ? null : desc,
                          ),
                        );
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

  void _showDeleteConfirmationDialog(
      BuildContext context, Freezer freezer, FreezerCubit cubit) {
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
                l10n.deleteFreezer,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deleteFreezerConfirm(freezer.name),
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
                      cubit.deleteFreezer(freezer.id);
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
