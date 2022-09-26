import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:location_alarm/core/constant_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceUtils {
  static final BackgroundServiceUtils _backgroundServiceUtils =
      BackgroundServiceUtils._privateConstructor();
  static final FlutterBackgroundService _backService =
      FlutterBackgroundService();

  factory BackgroundServiceUtils() => _backgroundServiceUtils;

  static BackgroundServiceUtils get instance => _backgroundServiceUtils;

  Future<bool> get isTracingTravel async =>
      ((await SharedPreferences.getInstance())
          .get(ConstantData.isTracingTravelKey) as bool?) ??
      false;

  Future<bool> setIsTracingTravel(bool value) async =>
      await (await SharedPreferences.getInstance())
          .setBool(ConstantData.isTracingTravelKey, value);

  FlutterBackgroundService get backService => _backService;

  BackgroundServiceUtils._privateConstructor();
}
