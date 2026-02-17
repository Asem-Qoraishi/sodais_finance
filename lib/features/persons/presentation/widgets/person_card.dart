import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/utils/formatters/relative_time_formatter.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.person, this.onTap});

  final Person person;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.45)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizeConstants.spacingSmall,
          vertical: sizeConstants.spacingXXSmall,
        ),
        leading: _buildAvatar(context),
        title: Row(
          children: [
            Expanded(
              child: Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: sizeConstants.spacingXSmall),
            Text(
              relativeTimeFormatter.formatPersonLastActive(
                context: context,
                date: person.updatedAt,
              ),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: sizeConstants.spacingXXSmall),
          child: _buildTypeBadges(context),
        ),
        trailing: _buildBalanceBadge(context),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final imageProvider = _getPersonImage(person.image);
    final initials = _buildNameInitials(person.name);
    final hasManyLetters = initials.length > 2;
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: sizeConstants.imageSmall / 2,
      backgroundImage: imageProvider,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: imageProvider == null
          ? Text(
              initials,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: hasManyLetters
                    ? sizeConstants.fontSmall
                    : sizeConstants.fontMedium,
              ),
            )
          : null,
    );
  }

  String _buildNameInitials(String fullName) {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    if (words.isEmpty) return '?';

    return words.map((word) => word.substring(0, 1)).join().toUpperCase();
  }

  ImageProvider<Object>? _getPersonImage(String? imagePath) {
    final path = imagePath?.trim() ?? '';
    if (path.isEmpty) return null;

    final file = File(path);
    if (!file.existsSync()) return null;

    return FileImage(file);
  }

  Widget _buildTypeBadges(BuildContext context) {
    final labels = switch (person.type) {
      PersonType.customer => [LocaleKeys.customer.tr()],
      PersonType.supplier => [LocaleKeys.supplier.tr()],
      PersonType.both => [LocaleKeys.customer.tr(), LocaleKeys.supplier.tr()],
    };

    return Wrap(
      spacing: sizeConstants.spacingXXSmall,
      runSpacing: sizeConstants.spacingXXSmall,
      children: labels.map((label) {
        final isSupplier = label == LocaleKeys.supplier.tr();
        final color = isSupplier
            ? Colors.purple.shade700
            : Colors.blue.shade700;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: sizeConstants.spacingXSmall,
            vertical: sizeConstants.spacingXXSmall - 1,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(sizeConstants.radiusXSmall),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBalanceBadge(BuildContext context) {
    final theme = Theme.of(context);

    if (person.balanceStatus == BalanceStatus.settled) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizeConstants.spacingXSmall,
          vertical: sizeConstants.spacingXXSmall,
        ),
        decoration: BoxDecoration(
          color: theme.hintColor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              size: sizeConstants.iconSmall,
              color: theme.hintColor,
            ),
            SizedBox(width: sizeConstants.spacingXXSmall),
            Text(
              LocaleKeys.settled.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final hasCredit = person.balance > 0;
    final accentColor = hasCredit ? Colors.blue.shade700 : Colors.red.shade700;
    final badgeIcon = hasCredit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeConstants.spacingXSmall,
        vertical: sizeConstants.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(sizeConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: accentColor, size: sizeConstants.iconSmall),
          SizedBox(width: sizeConstants.spacingXXSmall),
          Text(
            _formatMoney(person.balance.abs()),
            style: theme.textTheme.labelMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    return '\$${_withThousandsSeparator(parts[0])}.${parts[1]}';
  }

  String _withThousandsSeparator(String value) {
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
