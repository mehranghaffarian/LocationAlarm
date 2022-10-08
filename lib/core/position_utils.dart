import 'package:geolocator/geolocator.dart';
import 'package:location_alarm/core/notification_utils.dart';

class PositionUtils {
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) return null;

    Position? currentPosition;
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return currentPosition;
  }

  static Future<bool> handleLocationPermission(
      {bool checkForAlwaysAccess = false}) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await NotificationUtils.showNotification(body: "Please turn on the Location");

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return checkForAlwaysAccess ? permission == LocationPermission.always : true;
  }
}
