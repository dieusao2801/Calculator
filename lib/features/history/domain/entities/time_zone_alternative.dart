import 'package:equatable/equatable.dart';

class TimeZoneAlternative extends Equatable {
  final int? id;
  final String oldTimeZone;
  final String newTimeZone;
  final String rootCity;

  const TimeZoneAlternative({
    this.id,
    this.oldTimeZone = "",
    this.newTimeZone = "",
    this.rootCity = "",
  });

  @override
  List<Object?> get props => [id, oldTimeZone, newTimeZone, rootCity];
}