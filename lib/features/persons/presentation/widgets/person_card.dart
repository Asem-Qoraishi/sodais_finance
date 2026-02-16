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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        child: Ink(
          padding: EdgeInsets.all(sizeConstants.spacingSmall),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                child: person.image != null
                    ? Image.file(File(person.image!))
                    : Text(person.name.substring(0, 3).toUpperCase()),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(height: sizeConstants.spacingXSmall),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTypeBadges(context)),
                        SizedBox(width: sizeConstants.spacingXSmall),
                        _buildBalanceBadge(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  ImageProvider<Object>? _resolveAvatarImage(String? rawImage) {
    final image = rawImage?.trim() ?? '';
    if (image.isEmpty) return null;

    final file = File(image);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }
}
