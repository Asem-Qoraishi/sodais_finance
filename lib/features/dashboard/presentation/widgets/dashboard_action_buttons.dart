import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/colors.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';

const kDefaultDashboardQuickActions = <DashboardQuickActionType>[
  DashboardQuickActionType.newSale,
  DashboardQuickActionType.newPurchase,
  DashboardQuickActionType.receive,
  DashboardQuickActionType.payment,
  DashboardQuickActionType.newExpense,
];

enum DashboardQuickActionType {
  newSale,
  newPurchase,
  receive,
  payment,
  newExpense,
}

enum DashboardQuickActionGroup { trade, cashFlow, management }

enum DashboardQuickActionLayout { grid, list }

extension DashboardQuickActionGroupX on DashboardQuickActionGroup {
  String label(BuildContext context) {
    return switch (this) {
      DashboardQuickActionGroup.trade => LocaleKeys.trade.tr(),
      DashboardQuickActionGroup.cashFlow => LocaleKeys.cashFlow.tr(),
      DashboardQuickActionGroup.management => LocaleKeys.management.tr(),
    };
  }
}

extension DashboardQuickActionTypeX on DashboardQuickActionType {
  DashboardQuickActionGroup get group {
    return switch (this) {
      DashboardQuickActionType.newSale => DashboardQuickActionGroup.trade,
      DashboardQuickActionType.newPurchase => DashboardQuickActionGroup.trade,
      DashboardQuickActionType.receive => DashboardQuickActionGroup.cashFlow,
      DashboardQuickActionType.payment => DashboardQuickActionGroup.cashFlow,
      DashboardQuickActionType.newExpense =>
        DashboardQuickActionGroup.management,
    };
  }

  DashboardQuickActionLayout get layout {
    return switch (this) {
      DashboardQuickActionType.newSale => DashboardQuickActionLayout.grid,
      DashboardQuickActionType.newPurchase => DashboardQuickActionLayout.grid,
      DashboardQuickActionType.receive => DashboardQuickActionLayout.grid,
      DashboardQuickActionType.payment => DashboardQuickActionLayout.grid,
      DashboardQuickActionType.newExpense => DashboardQuickActionLayout.list,
    };
  }

  String title(BuildContext context) {
    return switch (this) {
      DashboardQuickActionType.newSale => LocaleKeys.newSale.tr(),
      DashboardQuickActionType.newPurchase => LocaleKeys.newPurchase.tr(),
      DashboardQuickActionType.receive => LocaleKeys.receive.tr(),
      DashboardQuickActionType.payment => LocaleKeys.payment.tr(),
      DashboardQuickActionType.newExpense => LocaleKeys.newExpense.tr(),
    };
  }

  String? subtitle(BuildContext context) {
    return switch (this) {
      DashboardQuickActionType.newExpense =>
        LocaleKeys.recordBusinessCosts.tr(),
      _ => null,
    };
  }

  IconData get iconData {
    return switch (this) {
      DashboardQuickActionType.newSale => Icons.shopping_bag_outlined,
      DashboardQuickActionType.newPurchase => Icons.inventory_2_outlined,
      DashboardQuickActionType.receive => Icons.arrow_downward,
      DashboardQuickActionType.payment => Icons.arrow_upward,
      DashboardQuickActionType.newExpense => Icons.receipt_long,
    };
  }

  Color get buttonColor {
    switch (this) {
      case DashboardQuickActionType.newSale:
        return kPrimaryColor;
      case DashboardQuickActionType.newPurchase:
        return kSecondaryColor;
      case DashboardQuickActionType.receive:
        return kSuccessColor;
      case DashboardQuickActionType.payment:
        return kErrorColor;
      case DashboardQuickActionType.newExpense:
        return kWarningHighlights;
    }
  }
}

class DashboardActionButtons extends StatelessWidget {
  const DashboardActionButtons({
    super.key,
    this.actions = kDefaultDashboardQuickActions,
    required this.onActionSelected,
  });

  final List<DashboardQuickActionType> actions;
  final ValueChanged<DashboardQuickActionType> onActionSelected;

  Future<void> _openQuickActions(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<DashboardQuickActionType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.60),
      builder: (_) => _DashboardQuickActionsSheet(actions: actions),
    );

    if (selectedAction != null) onActionSelected(selectedAction);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      heroTag: 'dashboard-quick-actions-fab',
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      onPressed: () => _openQuickActions(context),
      child: const Icon(Icons.add),
    );
  }
}

class _DashboardQuickActionsSheet extends StatelessWidget {
  const _DashboardQuickActionsSheet({required this.actions});

  final List<DashboardQuickActionType> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final groupedActions =
        <DashboardQuickActionGroup, List<DashboardQuickActionType>>{
          for (final group in DashboardQuickActionGroup.values)
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
                for (final group in DashboardQuickActionGroup.values)
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

  final List<DashboardQuickActionType> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final layout = actions.first.layout;
    if (layout == DashboardQuickActionLayout.grid) {
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

  final DashboardQuickActionType action;

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

  final DashboardQuickActionType action;

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
