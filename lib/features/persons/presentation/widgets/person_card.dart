import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/utils/formatters/date_formatter.dart';
import 'package:sodais_finance/features/persons/domain/person.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final avatarImage = _resolveAvatarImage(person.image);
    final subtitleParts = <String>[
      if ((person.phone?.trim().isNotEmpty ?? false)) person.phone!.trim(),
      if ((person.email?.trim().isNotEmpty ?? false)) person.email!.trim(),
    ];

    return ListTile(
      onTap: () {},
      dense: true,
      minVerticalPadding: sizeConstants.spacingSmall,
      leading: CircleAvatar(
        backgroundImage: avatarImage,
        child: avatarImage != null
            ? null
            : Text(person.name.isEmpty ? '?' : person.name[0].toUpperCase()),
      ),
      title: Row(
        children: [
          Expanded(child: Text(person.name, overflow: TextOverflow.ellipsis)),
          sizeConstants.spacingMedium.horizontalSpace,
          _buildTypeChip(context),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitleParts.isNotEmpty)
            Text(
              subtitleParts.join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            dateFormatter.formatDateToWeekDayAndMonthDayDate(
              context: context,
              date: person.updatedAt.toString(),
            ),
          ),
          if ((person.address?.trim().isNotEmpty ?? false))
            Text(
              person.address!.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            person.balance.toStringAsFixed(2),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: person.balanceStatus.color),
          ),
          Text(
            person.balanceStatus.name,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Text('#${person.id}', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  ImageProvider<Object>? _resolveAvatarImage(String? rawImage) {
    final image = rawImage?.trim() ?? '';
    if (image.isEmpty) return null;

    final normalized = image.toLowerCase();
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return NetworkImage(image);
    }

    final file = File(image);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  Widget _buildTypeChip(BuildContext context) {
    final color = switch (person.type) {
      PersonType.customer => const Color(0xFF0EA5E9),
      PersonType.supplier => const Color(0xFFF97316),
      PersonType.both => const Color(0xFF6366F1),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sizeConstants.spacingXXSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(sizeConstants.radiusXSmall),
      ),
      child: Text(
        person.type.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
