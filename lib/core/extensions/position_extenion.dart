import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

extension PositionExtension on Position{
  LatLng get equivalentLatLng => LatLng(latitude, longitude);
}