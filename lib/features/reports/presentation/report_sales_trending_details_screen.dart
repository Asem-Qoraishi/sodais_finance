import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sodais_finance/core/constants/size_constants.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/reports/domain/report_snapshot.dart';
import 'package:sodais_finance/features/reports/presentation/report_formatters.dart';

class ReportSalesTrendingDetailsScreen extends StatelessWidget {
  const ReportSalesTrendingDetailsScreen({super.key, required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final collected = math.min(
      snapshot.summary.cashIn,
      snapshot.summary.totalSales,
    ).toDouble();
    final outstanding = math.max(
      snapshot.summary.totalSales - collected,
      0.0,
    ).toDouble();
    final collectionRate = snapshot.summary.totalSales <= 0
        ? 0.0
        : ((collected / snapshot.summary.totalSales) * 100).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.salesTrending.tr())),
      body: ListView(
        padding: EdgeInsets.all(sizeConstants.spacingSmall),
        children: [
          _DetailPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ReportsFormatters.formatRange(context, snapshot.range),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: sizeConstants.spacingSmall),
                SizedBox(
                  height: 220,
                  child: CustomPaint(
                    painter: _SalesTrendPainter(
                      color: Theme.of(context).colorScheme.primary,
                      gridColor: Theme.of(context).dividerColor,
                      points: _trendPoints(snapshot),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: sizeConstants.spacingSmall,
            mainAxisSpacing: sizeConstants.spacingSmall,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricTile(
                label: LocaleKeys.total.tr(),
                value: ReportsFormatters.formatMoney(snapshot.summary.totalSales),
              ),
              _MetricTile(
                label: LocaleKeys.collectionRate.tr(),
                value: '${collectionRate.toStringAsFixed(1)}%',
              ),
              _MetricTile(
                label: LocaleKeys.collected.tr(),
                value: ReportsFormatters.formatMoney(collected),
              ),
              _MetricTile(
                label: LocaleKeys.outstanding.tr(),
                value: ReportsFormatters.formatMoney(outstanding),
              ),
            ],
          ),
          SizedBox(height: sizeConstants.spacingSmall),
          _DetailPanel(
            child: Column(
              children: [
                _DetailRow(
                  label: LocaleKeys.sale.tr(),
                  value:
                      '${snapshot.summary.salesCount} ${LocaleKeys.invoices.tr()}',
                ),
                _DetailRow(
                  label: LocaleKeys.purchase.tr(),
                  value:
                      '${snapshot.summary.purchaseCount} ${LocaleKeys.invoices.tr()}',
                ),
                _DetailRow(
                  label: LocaleKeys.receipt.tr(),
                  value: ReportsFormatters.formatMoney(snapshot.summary.cashIn),
                ),
                _DetailRow(
                  label: LocaleKeys.payment.tr(),
                  value: ReportsFormatters.formatMoney(snapshot.summary.cashOut),
                ),
                _DetailRow(
                  label: LocaleKeys.netCash.tr(),
                  value: ReportsFormatters.formatMoney(snapshot.summary.netCash),
                  emphasized: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _trendPoints(ReportsSnapshot snapshot) {
    final collected = math.min(
      snapshot.summary.cashIn,
      snapshot.summary.totalSales,
    ).toDouble();
    final outstanding = math.max(
      snapshot.summary.totalSales - collected,
      0.0,
    ).toDouble();

    return <double>[
      snapshot.summary.totalSales * 0.52,
      snapshot.summary.totalSales * 0.68,
      math.max(collected, snapshot.summary.totalSales * 0.8).toDouble(),
      math.max(
        snapshot.currentPosition.potentialRevenue - outstanding,
        snapshot.summary.totalSales * 0.92,
      ).toDouble(),
      math.max(
        snapshot.currentPosition.potentialRevenue,
        snapshot.summary.totalSales,
      ).toDouble(),
    ];
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(sizeConstants.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(height: sizeConstants.spacingXSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = emphasized
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizeConstants.spacingXSmall),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  const _SalesTrendPainter({
    required this.color,
    required this.gridColor,
    required this.points,
  });

  final Color color;
  final Color gridColor;
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (int index = 0; index < 5; index++) {
      final y = size.height * (index / 4);
      canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) return;
    final maxValue = points.reduce(math.max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final stepX = points.length == 1 ? 0.0 : size.width / (points.length - 1);

    final offsets = <Offset>[];
    for (int index = 0; index < points.length; index++) {
      final dx = index * stepX;
      final dy = size.height - ((points[index] / safeMax) * (size.height - 8)) - 4;
      offsets.add(Offset(dx, dy));
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int index = 1; index < offsets.length; index++) {
      final previous = offsets[index - 1];
      final current = offsets[index];
      final midX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(midX, previous.dy, midX, current.dy, current.dx, current.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.20), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SalesTrendPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.points != points;
  }
}
