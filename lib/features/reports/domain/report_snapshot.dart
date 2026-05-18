import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sodais_finance/core/localization/locale_keys.g.dart';
import 'package:sodais_finance/features/transactions/domain/transaction_feed_entry.dart';

enum ReportsRangePreset {
  last30Days,
  thisMonth,
  lastMonth,
  thisQuarter,
  thisYear,
  lastYear,
  customRange;

  String get label => switch (this) {
    ReportsRangePreset.last30Days => LocaleKeys.last30Days.tr(),
    ReportsRangePreset.thisMonth => LocaleKeys.thisMonth.tr(),
    ReportsRangePreset.lastMonth => LocaleKeys.lastMonth.tr(),
    ReportsRangePreset.thisQuarter => LocaleKeys.thisQuarter.tr(),
    ReportsRangePreset.thisYear => LocaleKeys.thisYear.tr(),
    ReportsRangePreset.lastYear => LocaleKeys.lastYear.tr(),
    ReportsRangePreset.customRange => LocaleKeys.customRange.tr(),
  };
}

class ReportsFilter {
  const ReportsFilter({required this.preset, this.customRange});

  const ReportsFilter.last30Days()
    : preset = ReportsRangePreset.last30Days,
      customRange = null;

  final ReportsRangePreset preset;
  final DateTimeRange? customRange;

  DateTimeRange? resolveRange(DateTime now) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = _endOfDay(now);
    final today = Jalali.fromDateTime(now);

    return switch (preset) {
      ReportsRangePreset.last30Days => DateTimeRange(
        start: startOfToday.subtract(const Duration(days: 29)),
        end: endOfToday,
      ),
      ReportsRangePreset.thisMonth => DateTimeRange(
        start: _startOfDay(Jalali(today.year, today.month, 1).toDateTime()),
        end: endOfToday,
      ),
      ReportsRangePreset.lastMonth => _lastMonthRange(today),
      ReportsRangePreset.thisQuarter => _thisQuarterRange(today, endOfToday),
      ReportsRangePreset.thisYear => DateTimeRange(
        start: _startOfDay(Jalali(today.year, 1, 1).toDateTime()),
        end: endOfToday,
      ),
      ReportsRangePreset.lastYear => _lastYearRange(today),
      ReportsRangePreset.customRange =>
        customRange == null
            ? null
            : DateTimeRange(
                start: DateTime(
                  customRange!.start.year,
                  customRange!.start.month,
                  customRange!.start.day,
                ),
                end: DateTime(
                  customRange!.end.year,
                  customRange!.end.month,
                  customRange!.end.day,
                  23,
                  59,
                  59,
                  999,
                ),
              ),
    };
  }

  DateTimeRange _lastMonthRange(Jalali today) {
    final lastMonth = today.month == 1
        ? Jalali(today.year - 1, 12, 1)
        : Jalali(today.year, today.month - 1, 1);

    final lastMonthEnd = Jalali(
      lastMonth.year,
      lastMonth.month,
      lastMonth.monthLength,
    );

    return DateTimeRange(
      start: _startOfDay(lastMonth.toDateTime()),
      end: _endOfDay(lastMonthEnd.toDateTime()),
    );
  }

  DateTimeRange _thisQuarterRange(Jalali today, DateTime endOfToday) {
    final quarterStartMonth = ((today.month - 1) ~/ 3) * 3 + 1;
    return DateTimeRange(
      start: _startOfDay(Jalali(today.year, quarterStartMonth, 1).toDateTime()),
      end: endOfToday,
    );
  }

  DateTimeRange _lastYearRange(Jalali today) {
    final lastYearStart = Jalali(today.year - 1, 1, 1);
    final lastYearEnd = Jalali(
      today.year - 1,
      12,
      Jalali(today.year - 1, 12).monthLength,
    );
    return DateTimeRange(
      start: _startOfDay(lastYearStart.toDateTime()),
      end: _endOfDay(lastYearEnd.toDateTime()),
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportsFilter &&
        other.preset == preset &&
        other.customRange?.start == customRange?.start &&
        other.customRange?.end == customRange?.end;
  }

  @override
  int get hashCode => Object.hash(preset, customRange?.start, customRange?.end);
}

class ReportsSnapshot {
  const ReportsSnapshot({
    required this.filter,
    required this.range,
    required this.summary,
    required this.currentPosition,
    required this.invoiceStatuses,
    required this.inventoryHealth,
    required this.topSellingProducts,
    required this.topCustomers,
    required this.topSuppliers,
    required this.recentActivity,
  });

  final ReportsFilter filter;
  final DateTimeRange? range;
  final ReportsSummary summary;
  final ReportsCurrentPosition currentPosition;
  final List<ReportInvoiceStatusItem> invoiceStatuses;
  final ReportsInventoryHealth inventoryHealth;
  final List<ReportTopProduct> topSellingProducts;
  final List<ReportTopContact> topCustomers;
  final List<ReportTopContact> topSuppliers;
  final List<TransactionFeedEntry> recentActivity;

  bool get hasPeriodActivity =>
      summary.invoiceCount > 0 ||
      summary.cashIn > 0 ||
      summary.cashOut > 0 ||
      recentActivity.isNotEmpty;
}

class ReportsSummary {
  const ReportsSummary({
    required this.totalSales,
    required this.totalPurchases,
    required this.cashIn,
    required this.cashOut,
    required this.invoiceCount,
    required this.salesCount,
    required this.purchaseCount,
  });

  final double totalSales;
  final double totalPurchases;
  final double cashIn;
  final double cashOut;
  final int invoiceCount;
  final int salesCount;
  final int purchaseCount;

  double get netCash => cashIn - cashOut;
}

class ReportsCurrentPosition {
  const ReportsCurrentPosition({
    required this.cashOnHand,
    required this.toCollect,
    required this.toPay,
    required this.inventoryValue,
    required this.potentialRevenue,
  });

  final double cashOnHand;
  final double toCollect;
  final double toPay;
  final double inventoryValue;
  final double potentialRevenue;
}

enum ReportInvoiceStatus { paid, partialPaid, unpaid }

class ReportInvoiceStatusItem {
  const ReportInvoiceStatusItem({
    required this.status,
    required this.count,
    required this.amount,
  });

  final ReportInvoiceStatus status;
  final int count;
  final double amount;

  String get label => switch (status) {
    ReportInvoiceStatus.paid => LocaleKeys.paid.tr(),
    ReportInvoiceStatus.partialPaid => LocaleKeys.partialPaid.tr(),
    ReportInvoiceStatus.unpaid => LocaleKeys.unpaid.tr(),
  };
}

class ReportsInventoryHealth {
  const ReportsInventoryHealth({
    required this.totalProducts,
    required this.totalUnits,
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.alerts,
  });

  final int totalProducts;
  final int totalUnits;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;
  final List<ReportInventoryAlert> alerts;
}

class ReportInventoryAlert {
  const ReportInventoryAlert({
    required this.id,
    required this.name,
    required this.stock,
    required this.reorderLevel,
    required this.outOfStock,
  });

  final String id;
  final String name;
  final int stock;
  final int reorderLevel;
  final bool outOfStock;

  bool get lowStock => !outOfStock && reorderLevel > 0 && stock <= reorderLevel;
}

class ReportTopProduct {
  const ReportTopProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.revenue,
    required this.currentStock,
  });

  final String id;
  final String name;
  final double quantity;
  final double revenue;
  final int currentStock;
}

class ReportTopContact {
  const ReportTopContact({
    required this.id,
    required this.name,
    required this.amount,
    required this.invoiceCount,
  });

  final String id;
  final String name;
  final double amount;
  final int invoiceCount;
}
