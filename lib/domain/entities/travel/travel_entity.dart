
import 'package:hive/hive.dart';

part 'travel_entity.g.dart';



/*
* never change any HiveField or HiveType number
* */


@HiveType(typeId: 0)
class TravelEntity {
  @HiveField(0)
  final String destinationName;
  @HiveField(1)
  final double destinationLat;
  @HiveField(2)
  final double destinationLong;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final double consideredDistance;

  TravelEntity({
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLong,
    required this.date,
    this.consideredDistance = 1000.0,
  });
}
