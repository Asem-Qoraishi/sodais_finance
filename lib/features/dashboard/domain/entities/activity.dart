import 'package:sodais_finance/features/dashboard/domain/enums/activity_type.dart';

class Activity {
  final String id;
  final String title;
  final ActivityType type;
  final String? description;
  final DateTime timestamp;

  const Activity({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    required this.timestamp,
  });
}
