import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/core/widgets/filters/filter_chip_bar.dart';
import 'package:sodais_finance/features/invoices/presentation/widgets/date_picker.dart';
import 'package:sodais_finance/features/reports/application/providers/reports_providers.dart';
import 'package:sodais_finance/features/reports/domain/report_snapshot.dart';
import 'package:sodais_finance/features/reports/presentation/report_formatters.dart';
import 'package:sodais_finance/features/reports/presentation/report_sales_trending_details_screen.dart';
import 'package:sodais_finance/features/reports/presentation/report_top_clients_details_screen.dart';
import 'package:sodais_finance/features/reports/presentation/report_top_items_details_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportsFilter _selectedFilter = const ReportsFilter.last30Days();

  Future<void> _refresh() async {
    ref.invalidate(reportsSnapshotProvider(_selectedFilter));
    await ref.read(reportsSnapshotProvider(_selectedFilter).future);
  }

  Future<void> _onFilterSelected(ReportsRangePreset preset) async {
    if (preset == ReportsRangePreset.customRange) {
      final range = await showModalBottomSheet<DateTimeRange>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => _CustomRangeSheet(
          initialRange: _selectedFilter.preset == ReportsRangePreset.customRange
              ? _selectedFilter.customRange
              : null,
        ),
      );

      if (!mounted || range == null) return;
      setState(() {
        _selectedFilter = ReportsFilter(
          preset: ReportsRangePreset.customRange,
          customRange: range,
        );
      });
      return;
    }

    setState(() {
      _selectedFilter = ReportsFilter(preset: preset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(reportsSnapshotProvider(_selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.reports.tr()),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: snapshotAsync.when(
        data: (snapshot) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              sizeConstants.spacingSmall,
              sizeConstants.spacingSmall,
              sizeConstants.spacingSmall,
              sizeConstants.spacingXXLarge,
            ),
            children: [
              FilterChipBar<ReportsRangePreset>(
                selectedValue: _selectedFilter.preset,
                options: ReportsRangePreset.values
                    .map(
                      (preset) =>
                          FilterChipOption(value: preset, label: preset.label),
                    )
                    .toList(growable: false),
                onSelected: _onFilterSelected,
              ),
              SizedBox(height: sizeConstants.spacingSmall),
              Text(
                ReportsFormatters.formatRange(context, snapshot.range),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: sizeConstants.spacingSmall),
              _ReportsMetricsGrid(snapshot: snapshot),
              SizedBox(height: sizeConstants.spacingMedium),
              _ReportPanel(
                child: _TrendSection(
                  snapshot: snapshot,
                  onMoreDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReportSalesTrendingDetailsScreen(
                          snapshot: snapshot,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: sizeConstants.spacingMedium),
              _ReportPanel(
                child: _BreakdownSection(
                  title: LocaleKeys.topClientsByRevenue.tr(),
                  centerLabel: _coverageLabel(snapshot.topCustomers),
                  values: snapshot.topCustomers
                      .take(2)
                      .map((item) => item.amount)
                      .toList(growable: false),
                  colors: _sectionColors(
                    context,
                  ).take(2).toList(growable: false),
                  onMoreDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportTopClientsDetailsScreen(snapshot: snapshot),
                      ),
                    );
                  },
                  legendChildren: snapshot.topCustomers
                      .take(2)
                      .toList(growable: false)
                      .asMap()
                      .entries
                      .map(
                        (entry) => _LegendRow(
                          color: _sectionColors(context)[entry.key],
                          label:
                              '${entry.value.name} (${entry.value.invoiceCount} ${LocaleKeys.invoices.tr()})',
                          value: ReportsFormatters.formatMoney(
                            entry.value.amount,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              SizedBox(height: sizeConstants.spacingMedium),
              _ReportPanel(
                child: _BreakdownSection(
                  title: LocaleKeys.topItemsBySales.tr(),
                  centerLabel: _coverageLabel(
                    snapshot.topSellingProducts
                        .map((item) => item.revenue)
                        .toList(),
                  ),
                  values: snapshot.topSellingProducts
                      .take(2)
                      .map((item) => item.revenue)
                      .toList(growable: false),
                  colors: _sectionColors(
                    context,
                  ).skip(2).take(2).toList(growable: false),
                  onMoreDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportTopItemsDetailsScreen(snapshot: snapshot),
                      ),
                    );
                  },
                  legendChildren: snapshot.topSellingProducts
                      .take(2)
                      .toList(growable: false)
                      .asMap()
                      .entries
                      .map(
                        (entry) => _LegendRow(
                          color: _sectionColors(context)[entry.key + 2],
                          label:
                              '${entry.value.name} (${LocaleKeys.quantity.tr()}: ${ReportsFormatters.formatQuantity(entry.value.quantity)})',
                          value: ReportsFormatters.formatMoney(
                            entry.value.revenue,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              if (!snapshot.hasPeriodActivity) ...[
                SizedBox(height: sizeConstants.spacingMedium),
                _ReportPanel(
                  child: Padding(
                    padding: EdgeInsets.all(sizeConstants.spacingMedium),
                    child: Text(
                      LocaleKeys.noReportData.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: EdgeInsets.all(sizeConstants.spacingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.failedToLoadReports.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                FilledButton(
                  onPressed: _refresh,
                  child: Text(LocaleKeys.retry.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _sectionColors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      const Color(0xFFC2822E),
    ];
  }

  String _coverageLabel(List<dynamic> entries) {
    if (entries.isEmpty) return '0%';

    final numericValues = entries
        .map((entry) {
          if (entry is ReportTopContact) return entry.amount;
          if (entry is double) return entry;
          return 0.0;
        })
        .toList(growable: false);

    final total = numericValues.fold<double>(0, (sum, value) => sum + value);
    final topTwo = numericValues
        .take(2)
        .fold<double>(0, (sum, value) => sum + value);

    if (total <= 0) return '0%';
    return '${((topTwo / total) * 100).clamp(0, 100).toStringAsFixed(0)}%';
  }
}

class _ReportsMetricsGrid extends StatelessWidget {
  const _ReportsMetricsGrid({required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final totalSales = snapshot.summary.totalSales;
    final collected = math.min(snapshot.summary.cashIn, totalSales).toDouble();
    final outstanding = math.max(totalSales - collected, 0.0).toDouble();
    final collectionRate = totalSales <= 0
        ? 0.0
        : ((collected / totalSales) * 100).clamp(0, 100);
    final averageInvoice = snapshot.summary.invoiceCount == 0
        ? 0.0
        : totalSales / snapshot.summary.invoiceCount;
    final overdueCount = snapshot.invoiceStatuses
        .firstWhere(
          (status) => status.status == ReportInvoiceStatus.unpaid,
          orElse: () => const ReportInvoiceStatusItem(
            status: ReportInvoiceStatus.unpaid,
            count: 0,
            amount: 0,
          ),
        )
        .count;

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      const Color(0xFFC2822E),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: sizeConstants.spacingSmall,
      mainAxisSpacing: sizeConstants.spacingSmall,
      childAspectRatio: 1.16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MetricCard(
          title: LocaleKeys.total.tr(),
          value: ReportsFormatters.formatMoney(totalSales),
          subtitle:
              '${snapshot.summary.invoiceCount} ${LocaleKeys.invoices.tr()}',
          accent: colors[0],
          icon: Icons.receipt_long_outlined,
        ),
        _MetricCard(
          title: LocaleKeys.collectionRate.tr(),
          value: '${collectionRate.toStringAsFixed(1)}%',
          subtitle:
              '${ReportsFormatters.formatMoney(averageInvoice)} ${LocaleKeys.avgInvoice.tr()}',
          accent: colors[1],
          icon: Icons.percent_rounded,
        ),
        _MetricCard(
          title: LocaleKeys.collected.tr(),
          value: ReportsFormatters.formatMoney(collected),
          subtitle: '$overdueCount ${LocaleKeys.overdue.tr()}',
          accent: colors[2],
          icon: Icons.payments_outlined,
        ),
        _MetricCard(
          title: LocaleKeys.outstanding.tr(),
          value: ReportsFormatters.formatMoney(outstanding),
          subtitle: LocaleKeys.openBalance.tr(),
          accent: colors[3],
          icon: Icons.pending_actions_outlined,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusMedium),
        border: Border.all(color: theme.dividerColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            accent.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.08 : 0.05,
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sizeConstants.radiusMedium),
                  topRight: Radius.circular(sizeConstants.radiusMedium),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sizeConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    Icon(icon, color: accent),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: sizeConstants.spacingXXSmall),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportPanel extends StatelessWidget {
  const _ReportPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({required this.snapshot, required this.onMoreDetails});

  final ReportsSnapshot snapshot;
  final VoidCallback onMoreDetails;

  @override
  Widget build(BuildContext context) {
    final points = _trendPoints(snapshot);
    final maxValue = points.isEmpty ? 0.0 : points.reduce(math.max);

    return Padding(
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: LocaleKeys.salesTrending.tr(),
            onMoreDetails: onMoreDetails,
          ),
          SizedBox(height: sizeConstants.spacingMedium),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final value in _axisValues(maxValue))
                        Text(
                          ReportsFormatters.compactMoney(value),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: sizeConstants.spacingSmall),
                Expanded(
                  child: CustomPaint(
                    painter: _TrendPainter(
                      points: points,
                      lineColor: Theme.of(context).colorScheme.primary,
                      gridColor: Theme.of(context).dividerColor,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snapshot.range == null
                    ? LocaleKeys.all.tr()
                    : ReportsFormatters.formatDate(
                        context,
                        snapshot.range!.start,
                      ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                LocaleKeys.currentPosition.tr(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<double> _trendPoints(ReportsSnapshot snapshot) {
    final totalSales = snapshot.summary.totalSales;
    final collected = math.min(snapshot.summary.cashIn, totalSales).toDouble();
    final pending = math.max(totalSales - collected, 0.0).toDouble();
    final inventoryValue = snapshot.currentPosition.inventoryValue;
    final potentialRevenue = snapshot.currentPosition.potentialRevenue;

    return <double>[
      totalSales * 0.55,
      totalSales * 0.72,
      math.max(collected, totalSales * 0.8).toDouble(),
      math.max(inventoryValue, totalSales * 0.88).toDouble(),
      math.max(potentialRevenue - pending, totalSales * 0.96).toDouble(),
    ].map((value) => value.isFinite ? value : 0.0).toList(growable: false);
  }

  List<double> _axisValues(double maxValue) {
    final ceiling = maxValue <= 0 ? 1.0 : maxValue;
    return [ceiling, ceiling * 0.75, ceiling * 0.5, ceiling * 0.25, 0];
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({
    required this.title,
    required this.centerLabel,
    required this.values,
    required this.colors,
    required this.onMoreDetails,
    required this.legendChildren,
  });

  final String title;
  final String centerLabel;
  final List<double> values;
  final List<Color> colors;
  final VoidCallback onMoreDetails;
  final List<Widget> legendChildren;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, onMoreDetails: onMoreDetails),
          SizedBox(height: sizeConstants.spacingMedium),
          Row(
            children: [
              _RingChart(
                values: values,
                colors: colors,
                centerLabel: centerLabel,
              ),
              SizedBox(width: sizeConstants.spacingMedium),
              Expanded(
                child: Column(
                  children: legendChildren.isEmpty
                      ? [
                          Text(
                            LocaleKeys.noReportData.tr(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ]
                      : [
                          for (
                            int index = 0;
                            index < legendChildren.length;
                            index++
                          ) ...[
                            if (index > 0)
                              SizedBox(height: sizeConstants.spacingSmall),
                            legendChildren[index],
                          ],
                        ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onMoreDetails});

  final String title;
  final VoidCallback onMoreDetails;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(
          onPressed: onMoreDetails,
          child: Text(LocaleKeys.moreDetails.tr()),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: sizeConstants.spacingXSmall),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: sizeConstants.spacingSmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _RingChart extends StatelessWidget {
  const _RingChart({
    required this.values,
    required this.colors,
    required this.centerLabel,
  });

  final List<double> values;
  final List<Color> colors;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(112),
            painter: _RingChartPainter(
              values: values,
              colors: colors,
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Text(
            centerLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
  });

  final List<double> points;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.42)
      ..strokeWidth = 1;

    for (int index = 0; index < 5; index++) {
      final y = size.height * (index / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) return;

    final maxValue = points.reduce(math.max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final stepX = points.length == 1 ? 0.0 : size.width / (points.length - 1);
    final offsets = <Offset>[];

    for (int index = 0; index < points.length; index++) {
      final dx = index * stepX;
      final dy =
          size.height - ((points[index] / safeMax) * (size.height - 8)) - 4;
      offsets.add(Offset(dx, dy));
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int index = 1; index < offsets.length; index++) {
      final previous = offsets[index - 1];
      final current = offsets[index];
      final midX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        midX,
        previous.dy,
        midX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: 0.20), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _RingChartPainter extends CustomPainter {
  const _RingChartPainter({
    required this.values,
    required this.colors,
    required this.baseColor,
  });

  final List<double> values;
  final List<Color> colors;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = baseColor;

    canvas.drawCircle(center, radius, basePaint);

    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0 || colors.isEmpty) return;

    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    var startAngle = -math.pi / 2;
    for (int index = 0; index < values.length; index++) {
      final sweep = (values[index] / total) * math.pi * 2;
      if (sweep <= 0) continue;
      segmentPaint.color = colors[index % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        segmentPaint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.baseColor != baseColor;
  }
}

class _CustomRangeSheet extends StatefulWidget {
  const _CustomRangeSheet({this.initialRange});

  final DateTimeRange? initialRange;

  @override
  State<_CustomRangeSheet> createState() => _CustomRangeSheetState();
}

class _CustomRangeSheetState extends State<_CustomRangeSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange?.start;
    _endDate = widget.initialRange?.end;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizeConstants.spacingMedium,
        sizeConstants.spacingSmall,
        sizeConstants.spacingMedium,
        MediaQuery.of(context).viewInsets.bottom + sizeConstants.spacingMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.customRange.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          CustomDatePicker(
            date: _startDate,
            onPickedDate: (value) => setState(() => _startDate = value),
            label: LocaleKeys.startDate.tr(),
            useJalaliCalendar: true,
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          CustomDatePicker(
            date: _endDate,
            onPickedDate: (value) => setState(() => _endDate = value),
            label: LocaleKeys.endDate.tr(),
            useJalaliCalendar: true,
          ),
          SizedBox(height: sizeConstants.spacingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(LocaleKeys.cancel.tr()),
                ),
              ),
              SizedBox(width: sizeConstants.spacingSmall),
              Expanded(
                child: FilledButton(
                  onPressed: _apply,
                  child: Text(LocaleKeys.apply.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _apply() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.customRangeInvalid.tr())),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.customRangeInvalid.tr())),
      );
      return;
    }

    Navigator.of(
      context,
    ).pop(DateTimeRange(start: _startDate!, end: _endDate!));
  }
}
