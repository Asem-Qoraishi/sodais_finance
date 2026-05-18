import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/reports/domain/report_snapshot.dart';
import 'package:sodais_finance/features/reports/presentation/report_formatters.dart';

class ReportTopClientsDetailsScreen extends StatelessWidget {
  const ReportTopClientsDetailsScreen({super.key, required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.topClientsByRevenue.tr())),
      body: ListView(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        children: [
          _ContactsPanel(
            title: LocaleKeys.customers.tr(),
            contacts: snapshot.topCustomers,
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          _ContactsPanel(
            title: LocaleKeys.suppliers.tr(),
            contacts: snapshot.topSuppliers,
          ),
        ],
      ),
    );
  }
}

class _ContactsPanel extends StatelessWidget {
  const _ContactsPanel({required this.title, required this.contacts});

  final String title;
  final List<ReportTopContact> contacts;

  @override
  Widget build(BuildContext context) {
    final highestAmount = contacts.isEmpty
        ? 1.0
        : contacts.first.amount <= 0
        ? 1.0
        : contacts.first.amount;

    return Container(
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          if (contacts.isEmpty)
            Text(
              LocaleKeys.noReportData.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            )
          else
            for (int index = 0; index < contacts.length; index++) ...[
              if (index > 0) SizedBox(height: sizeConstants.spacingSmall),
              _ContactRow(
                rank: index + 1,
                contact: contacts[index],
                progress: contacts[index].amount / highestAmount,
              ),
            ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.rank,
    required this.contact,
    required this.progress,
  });

  final int rank;
  final ReportTopContact contact;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = rank.isOdd
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: sizeConstants.avatarXSmall,
              height: sizeConstants.avatarXSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
              ),
              child: Text(
                rank.toString(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: sizeConstants.spacingXXSmall),
                  Text(
                    '${contact.invoiceCount} ${LocaleKeys.invoices.tr()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sizeConstants.spacingSmall),
            Text(
              ReportsFormatters.formatMoney(contact.amount),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: sizeConstants.spacingXSmall),
        ClipRRect(
          borderRadius: BorderRadius.circular(sizeConstants.radiusMax),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
