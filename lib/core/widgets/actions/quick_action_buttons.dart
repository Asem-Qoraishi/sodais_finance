import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

const kDefaultQuickActions = <QuickActionType>[
  QuickActionType.newSale,
  QuickActionType.newPurchase,
  QuickActionType.receive,
  QuickActionType.payment,
  QuickActionType.newExpense,
];

enum QuickActionType { newSale, newPurchase, receive, payment, newExpense }

enum QuickActionGroup { trade, cashFlow, management }

enum QuickActionLayout { grid, list }

extension QuickActionGroupX on QuickActionGroup {
  String label(BuildContext context) {
    return switch (this) {
      QuickActionGroup.trade => LocaleKeys.trade.tr(),
      QuickActionGroup.cashFlow => LocaleKeys.cashFlow.tr(),
      QuickActionGroup.management => LocaleKeys.management.tr(),
    };
  }
}

extension QuickActionTypeX on QuickActionType {
  QuickActionGroup get group {
    return switch (this) {
      QuickActionType.newSale => QuickActionGroup.trade,
      QuickActionType.newPurchase => QuickActionGroup.trade,
      QuickActionType.receive => QuickActionGroup.cashFlow,
      QuickActionType.payment => QuickActionGroup.cashFlow,
      QuickActionType.newExpense => QuickActionGroup.management,
    };
  }

  QuickActionLayout get layout {
    return switch (this) {
      QuickActionType.newSale => QuickActionLayout.grid,
      QuickActionType.newPurchase => QuickActionLayout.grid,
      QuickActionType.receive => QuickActionLayout.grid,
      QuickActionType.payment => QuickActionLayout.grid,
      QuickActionType.newExpense => QuickActionLayout.list,
    };
  }

  String title(BuildContext context) {
    return switch (this) {
      QuickActionType.newSale => LocaleKeys.newSale.tr(),
      QuickActionType.newPurchase => LocaleKeys.newPurchase.tr(),
      QuickActionType.receive => LocaleKeys.receive.tr(),
      QuickActionType.payment => LocaleKeys.payment.tr(),
      QuickActionType.newExpense => LocaleKeys.newExpense.tr(),
    };
  }

  String? subtitle(BuildContext context) {
    return switch (this) {
      QuickActionType.newExpense => LocaleKeys.recordBusinessCosts.tr(),
      _ => null,
    };
  }

  IconData get iconData {
    return switch (this) {
      QuickActionType.newSale => Icons.shopping_bag_outlined,
      QuickActionType.newPurchase => Icons.inventory_2_outlined,
      QuickActionType.receive => Icons.arrow_downward,
      QuickActionType.payment => Icons.arrow_upward,
      QuickActionType.newExpense => Icons.receipt_long,
    };
  }

  Color get buttonColor {
    switch (this) {
      case QuickActionType.newSale:
        return kPrimaryColor;
      case QuickActionType.newPurchase:
        return kSecondaryColor;
      case QuickActionType.receive:
        return kSuccessColor;
      case QuickActionType.payment:
        return kErrorColor;
      case QuickActionType.newExpense:
        return kWarningHighlights;
    }
  }
}

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({
    super.key,
    this.actions = kDefaultQuickActions,
    required this.onActionSelected,
  });

  final List<QuickActionType> actions;
  final ValueChanged<QuickActionType> onActionSelected;

  Future<void> _openQuickActions(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<QuickActionType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.60),
      builder: (_) => _QuickActionsSheet(actions: actions),
    );

    if (selectedAction != null) onActionSelected(selectedAction);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      heroTag: 'quick-actions-fab',
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      onPressed: () => _openQuickActions(context),
      child: const Icon(Icons.add),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({required this.actions});

  final List<QuickActionType> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final groupedActions = <QuickActionGroup, List<QuickActionType>>{
      for (final group in QuickActionGroup.values)
        group: actions.where((action) => action.group == group).toList(),
    };

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sizeConstants.radiusXLarge * 1.35),
          ),
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              sizeConstants.spacingMedium,
              sizeConstants.spacingXSmall,
              sizeConstants.spacingMedium,
              sizeConstants.spacingMedium + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: sizeConstants.spacingXLarge * 1.3,
                    height: sizeConstants.spacingXXSmall * 1.5,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(
                        sizeConstants.radiusMax,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sizeConstants.spacingMedium),
                for (final group in QuickActionGroup.values)
                  if ((groupedActions[group] ?? const []).isNotEmpty) ...[
                    _ActionSectionHeader(title: group.label(context)),
                    SizedBox(height: sizeConstants.spacingSmall),
                    _ActionSection(actions: groupedActions[group] ?? const []),
                    SizedBox(height: sizeConstants.spacingMedium),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSectionHeader extends StatelessWidget {
  const _ActionSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizeConstants.spacingXSmall),
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.actions});

  final List<QuickActionType> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final layout = actions.first.layout;
    if (layout == QuickActionLayout.grid) {
      return GridView.builder(
        itemCount: actions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: sizeConstants.spacingSmall,
          mainAxisSpacing: sizeConstants.spacingSmall,
          mainAxisExtent: sizeConstants.buttonHeightLarge * 1.9,
        ),
        itemBuilder: (context, index) =>
            _GridActionCard(action: actions[index]),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          _ListActionCard(action: actions[i]),
          if (i != actions.length - 1)
            SizedBox(height: sizeConstants.spacingSmall),
        ],
      ],
    );
  }
}

class _GridActionCard extends StatelessWidget {
  const _GridActionCard({required this.action});

  final QuickActionType action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(sizeConstants.spacingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                decoration: BoxDecoration(
                  color: action.buttonColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusMedium,
                  ),
                  border: Border.all(
                    color: action.buttonColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  action.iconData,
                  color: action.buttonColor,
                  size: sizeConstants.iconMedium,
                ),
              ),
              const Spacer(),
              Text(
                action.title(context),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListActionCard extends StatelessWidget {
  const _ListActionCard({required this.action});

  final QuickActionType action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(sizeConstants.spacingSmall),
          child: Row(
            children: [
              Container(
                width: sizeConstants.avatarXSmall,
                height: sizeConstants.avatarXSmall,
                decoration: BoxDecoration(
                  color: action.buttonColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    sizeConstants.radiusMedium,
                  ),
                  border: Border.all(
                    color: action.buttonColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  action.iconData,
                  color: action.buttonColor,
                  size: sizeConstants.iconMedium,
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (action.subtitle(context) case final subtitle?)
                      Padding(
                        padding: EdgeInsets.only(
                          top: sizeConstants.spacingXXSmall,
                        ),
                        child: Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.hintColor,
                size: sizeConstants.iconMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
