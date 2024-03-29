import 'package:latlong2/latlong.dart';

abstract class ConstantData{
  static const chasingLocationTaskName = 'chasing_location_task_name';
  static const userArrived = 'userArrived';
  static const cancelTrip = 'cancelTrip';
  static const travelsDatabaseName = 'travels';
  static final AUTLatLng = LatLng(35.7031114, 51.4097108);
  static const tripKey = "tripKey";

  static const destinationLatKey = "destinationLatKey";
  static const destinationLongKey = "destinationLongKey";
  static const destinationNameKey = "destinationNameKey";
  static const isTracingTravelKey = "isTracingTravelKey";
  static const tripDateKey = "tripDateKey";
  static const tripDistanceKey = "tripDistanceKey";
  static const tripConsideredDistanceKey = "tripConsideredDistanceKey";

  //settings
  static int arrivedNotifCount = 5;
  static const arrivedNotifCountKey = 'arrivedNotifCount';
  static const isLogEnabledKey = "isLogEnabledKey";
}