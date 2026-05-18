import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sodais_finance/features/app/data/app_database.dart';
import 'package:sodais_finance/features/reports/data/local/reports_query_service.dart';
import 'package:sodais_finance/features/reports/domain/report_snapshot.dart';

final reportsQueryServiceProvider = Provider<ReportsQueryService>((ref) {
  return ReportsQueryService(ref.watch(appDatabaseProvider));
});

final reportsSnapshotProvider =
    StreamProvider.family<ReportsSnapshot, ReportsFilter>((ref, filter) {
      return ref.watch(reportsQueryServiceProvider).watchSnapshot(filter);
    });
