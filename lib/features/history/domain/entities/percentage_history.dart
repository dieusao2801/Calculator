import 'package:equatable/equatable.dart';

class PercentageHistory extends Equatable {
  final int? id;
  final DateTime createdTime;
  final String? initialValue;
  final String? percentValue;
  final String? changeValue;
  final String? finalValue;
  final int? changedPosition1;
  final int? changedPosition2;

  const PercentageHistory({
    this.id,
    required this.createdTime,
    this.initialValue,
    this.percentValue,
    this.changeValue,
    this.finalValue,
    this.changedPosition1,
    this.changedPosition2,
  });

  @override
  List<Object?> get props => [
    id,
    createdTime,
    initialValue,
    percentValue,
    changeValue,
    finalValue,
    changedPosition1,
    changedPosition2,
  ];
}