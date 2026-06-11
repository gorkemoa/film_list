import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../app/translations.dart';
import '../../core/responsive/size_config.dart';
import '../../core/responsive/size_tokens.dart';
import '../../models/custom_list.dart';
import '../../viewmodels/custom_list_view_model.dart';
import 'custom_list_detail_view.dart';

class ListsView extends StatefulWidget {
  const ListsView({super.key});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomListViewModel>().init();
    });
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.radiusMedium),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: SizeTokens.paddingMedium,
            right: SizeTokens.paddingMedium,
            top: SizeTokens.paddingLarge,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom +
                SizeTokens.paddingLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.tr('createList'),
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: SizeTokens.textLarge,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: SizeTokens.paddingMedium),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimaryColor),
                decoration: InputDecoration(
                  hintText: Translations.tr('listNameHint'),
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceLightColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeTokens.radiusSmall),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: SizeTokens.paddingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    context.read<CustomListViewModel>().createList(name);
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: SizeTokens.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        SizeTokens.radiusSmall,
                      ),
                    ),
                  ),
                  child: Text(
                    Translations.tr('save'),
                    style: TextStyle(
                      fontSize: SizeTokens.textMedium,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(CustomList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            Translations.tr('deleteList'),
            style: const TextStyle(color: AppTheme.textPrimaryColor),
          ),
          content: Text(
            Translations.tr('deleteListConfirm'),
            style: const TextStyle(color: AppTheme.textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                Translations.tr('cancel'),
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                Translations.tr('delete'),
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await context.read<CustomListViewModel>().deleteList(list.id);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Consumer<CustomListViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: viewModel.init,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              SizeTokens.paddingMedium,
              SizeTokens.paddingMedium,
              SizeTokens.paddingMedium,
              SizeConfig.relativeSize(92),
            ),
            children: [
              _buildHeader(),
              SizedBox(height: SizeTokens.paddingMedium),
              if (viewModel.errorMessage != null)
                _buildError(viewModel.errorMessage!)
              else if (viewModel.lists.isEmpty)
                _buildEmptyState()
              else
                ...viewModel.lists.map((list) {
                  return _ListRow(
                    list: list,
                    itemCount: list.movieIds.length,
                    onTap: () => _openList(list),
                    onDelete: () => _confirmDelete(list),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.tr('myLists'),
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: SizeTokens.textTitle,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: SizeTokens.paddingMin),
              Text(
                Translations.tr('organizeYourMovies'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: SizeTokens.textSmall,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: SizeTokens.paddingMedium),
        FilledButton.icon(
          onPressed: _showCreateListDialog,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.paddingMedium,
              vertical: SizeTokens.paddingSmall,
            ),
          ),
          icon: Icon(Icons.add_rounded, size: SizeTokens.iconSmall),
          label: Text(
            Translations.tr('create'),
            style: TextStyle(
              fontSize: SizeTokens.textSmall,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: EdgeInsets.only(top: SizeTokens.paddingLarge),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.errorColor,
          fontSize: SizeTokens.textMedium,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.only(top: SizeTokens.paddingLarge),
      padding: EdgeInsets.all(SizeTokens.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: SizeTokens.circularRadiusMedium,
        border: Border.all(color: AppTheme.surfaceLightColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.playlist_add_rounded,
            color: AppTheme.textTertiaryColor,
            size: SizeTokens.iconXLarge,
          ),
          SizedBox(height: SizeTokens.paddingMedium),
          Text(
            Translations.tr('noCustomLists'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: SizeTokens.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _openList(CustomList list) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomListDetailView(customList: list)),
    ).then((_) {
      if (!mounted) return;
      context.read<CustomListViewModel>().init();
    });
  }
}

class _ListRow extends StatelessWidget {
  final CustomList list;
  final int itemCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ListRow({
    required this.list,
    required this.itemCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.paddingSmall),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: SizeTokens.circularRadiusSmall,
        border: Border.all(color: AppTheme.surfaceLightColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeTokens.paddingMedium,
          vertical: SizeTokens.paddingMin,
        ),
        leading: Container(
          width: SizeTokens.heightMedium,
          height: SizeTokens.heightMedium,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLightColor,
            borderRadius: SizeTokens.circularRadiusSmall,
          ),
          child: const Icon(
            Icons.playlist_play_rounded,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          list.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: SizeTokens.textMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '$itemCount ${Translations.tr('items')}',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: SizeTokens.textSmall,
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
