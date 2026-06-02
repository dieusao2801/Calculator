import 'package:calculator/features/history/domain/entities/time_zone_alternative.dart';

abstract class TimeZoneAlternativeRepository {
  Future<List<TimeZoneAlternative>> getAllTimeZoneAlternatives();
  Future<void> saveTimeZoneAlternative(TimeZoneAlternative data);
  Future<void> deleteTimeZoneAlternative(int id);
  Future<void> clearAll();
}