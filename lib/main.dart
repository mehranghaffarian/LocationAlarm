import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location_alarm/core/background_service_utils.dart';
import 'package:location_alarm/core/constant_data.dart';
import 'package:location_alarm/core/notification_utils.dart';
import 'package:location_alarm/core/position_utils.dart';
import 'package:location_alarm/domain/entities/travel/travel_entity.dart';
import 'package:location_alarm/presentation/pages/about/about_page.dart';
import 'package:location_alarm/presentation/pages/choose_destination/choose_destination_page.dart';
import 'package:location_alarm/presentation/pages/history/history.dart';
import 'package:location_alarm/presentation/pages/home_page/home_page.dart';
import 'package:location_alarm/presentation/pages/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();
  await initDB();

  runApp(const LocationAlarm());
}

class LocationAlarm extends StatefulWidget {
  const LocationAlarm({Key? key}) : super(key: key);

  @override
  State<LocationAlarm> createState() => _LocationAlarmState();
}

class _LocationAlarmState extends State<LocationAlarm> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromRGBO(18, 78, 1, 1.0),
          onPrimary: Color.fromRGBO(18, 78, 1, 1.0),
          secondary: Color.fromRGBO(1, 61, 134, 1.0),
          onSecondary: Color.fromRGBO(18, 78, 1, 1.0),
          error: Color.fromRGBO(18, 78, 1, 1.0),
          onError: Color.fromRGBO(18, 78, 1, 1.0),
          background: Color.fromRGBO(18, 78, 1, 1.0),
          onBackground: Color.fromRGBO(18, 78, 1, 1.0),
          surface: Color.fromRGBO(18, 78, 1, 1.0),
          onSurface: Color.fromRGBO(18, 78, 1, 1.0),
        ),
        primaryColor: const Color.fromRGBO(65, 135, 44, 1.0),
        primaryColorDark: const Color.fromRGBO(18, 78, 1, 1.0),
        errorColor: const Color.fromRGBO(150, 20, 20, 1.0),
        backgroundColor: const Color.fromRGBO(126, 212, 142, 1.0),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            fontSize: 18,
            color: Color.fromRGBO(65, 135, 44, 1.0),
          ),
          titleSmall: TextStyle(
            fontSize: 15,
            color: Color.fromRGBO(65, 135, 44, 1.0),
          ),
          titleLarge: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(150, 20, 20, 1.0),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (ctx) => HomePage(),
        History.routeName: (ctx) => History(),
        ChooseDestinationPage.routeName: (ctx) => ChooseDestinationPage(),
        Settings.routeName: (ctx) => const Settings(),
        AboutPage.routeName: (ctx) => const AboutPage(),
      },
    );
  }

  @override
  void initState() {
    super.initState();

    FlutterLocalNotificationsPlugin().initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(),
      ),
      onSelectNotification: (payload) async {},
    );

    _fetchSettings();
  }

  @override
  void dispose() async {
    super.dispose();
    await Hive.close();
  }

  _fetchSettings() async {
    ConstantData.arrivedNotifCount = (await SharedPreferences.getInstance())
            .getInt(ConstantData.arrivedNotifCountKey) ??
        5;
  }
}

Future<dynamic> backTask({
  required double destinationLat,
  required double destinationLon,
  required double consideredDistance,
  required String destinationName,
}) async {
  var isLogEnabled = false;
  SharedPreferences.getInstance().then((value) =>
      isLogEnabled = value.getBool(ConstantData.isLogEnabledKey) ?? false);
  await BackgroundServiceUtils.instance.setIsTracingTravel(true);

  NotificationUtils.showNotification(
    body:
        "now Im in the background, I will let you know when you have arrived.",
  );

  double? previousDistance;

  while (true) {
    var currentPosition = await PositionUtils.getCurrentPosition();

    if (currentPosition == null) {
      NotificationUtils.showNotification(
          body:
              "I could not get your location, trying again in 10 seconds....");
      await Future.delayed(
          const Duration(seconds: 10),
          () async =>
              currentPosition = await PositionUtils.getCurrentPosition());
      if (currentPosition == null) {
        await NotificationUtils.showNotificationWithWatchDelay(
          body: 'I could not get your location',
        );
        BackgroundServiceUtils.instance.backService
            .invoke(ConstantData.cancelTrip);
        return false;
      } else {
        await NotificationUtils.showNotificationWithWatchDelay(
          body: 'Problem solved',
        );
      }
    }

    final distance = GeolocatorPlatform.instance.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      destinationLat,
      destinationLon,
    );

    if (distance < consideredDistance) {
      final service = BackgroundServiceUtils.instance.backService;

      service.invoke(ConstantData.userArrived, {
        ConstantData.tripDistanceKey: distance,
        ConstantData.destinationNameKey: destinationName,
        ConstantData.destinationLatKey: destinationLat,
        ConstantData.destinationLongKey: destinationLon,
        ConstantData.tripConsideredDistanceKey: consideredDistance,
      });
      return true;
    } else if (previousDistance == null ? false : previousDistance < distance) {
      await NotificationUtils.showNotification(
          body: "Seems you are getting further from your destination.");
    } else {
      final double expectedRequiredTime = distance /
          (previousDistance == null ? 1 : (previousDistance - distance)) /
          10;
      final double checkTimeDelay = expectedRequiredTime > 20
          ? 20
          : expectedRequiredTime < 5
              ? 5
              : expectedRequiredTime; //setting time to check again between 20 and 5 seconds

      if (isLogEnabled) {
        await NotificationUtils.showNotificationWithWatchDelay(
          body:
              'distance: $distance, checkTimeDelay: $checkTimeDelay, expectedRequiredTime: $expectedRequiredTime',
        );
      }

      await Future.delayed(Duration(seconds: checkTimeDelay.toInt()), () {});
    }
    previousDistance = distance;
  }
}

Future<void> initializeService() async {
  final service = BackgroundServiceUtils.instance.backService;
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      foregroundServiceNotificationTitle: 'Location Alarm',
      foregroundServiceNotificationContent: 'handling background',
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onStart,
    ),
  );
}

Future<bool> onStart(ServiceInstance service) async {
  await initDB();

  DartPluginRegistrant.ensureInitialized();

  service.on(ConstantData.chasingLocationTaskName).listen((event) async {
    if (!(await BackgroundServiceUtils.instance.isTracingTravel)) {
      try {
        final destinationLat = event![ConstantData.destinationLatKey];
        final destinationLong = event[ConstantData.destinationLongKey];
        final destinationName = event[ConstantData.destinationNameKey];
        final consideredDistance = double.tryParse(
                event[ConstantData.tripConsideredDistanceKey].toString()) ??
            1000.0;

        backTask(
          destinationLat: destinationLat,
          destinationLon: destinationLong,
          destinationName: destinationName,
          consideredDistance: consideredDistance,
        );
      } catch (e) {
        await NotificationUtils.showNotificationWithWatchDelay(
            body: 'You faced an error: $e');
        await BackgroundServiceUtils.instance.setIsTracingTravel(false);
        service.stopSelf();
      }
    } else {
      await NotificationUtils.showNotificationWithWatchDelay(
          body: 'You have a registered travel first cancel it');
    }
  });
  service.on(ConstantData.userArrived).listen((event) async {
    final notifCount = (await SharedPreferences.getInstance())
            .getInt(ConstantData.arrivedNotifCountKey) ??
        ConstantData.arrivedNotifCount;

    for (int i = 1; i <= notifCount; i++) {
      await NotificationUtils.showNotification(
        payload: 'payload',
        title: 'you have arrived to ${event![ConstantData.destinationNameKey]}',
        body:
            'distance: ${event[ConstantData.tripDistanceKey]}, considered distance: ${event[ConstantData.tripConsideredDistanceKey]}',
        ID: i,
      );
      await Future.delayed(const Duration(seconds: 3), () {});
    }
    await saveRecord(
      destinationName: event![ConstantData.destinationNameKey],
      destinationLat: event[ConstantData.destinationLatKey],
      destinationLong: event[ConstantData.destinationLongKey],
      consideredDistance: double.tryParse(
              event[ConstantData.tripConsideredDistanceKey].toString()) ??
          0.0,
    );

    await BackgroundServiceUtils.instance.setIsTracingTravel(false);
    service.stopSelf();
  });
  service.on(ConstantData.cancelTrip).listen((event) async {
    await BackgroundServiceUtils.instance.setIsTracingTravel(false);
    service.stopSelf();

    await NotificationUtils.showNotificationWithWatchDelay(
        body: 'your trip has been canceled');
  });
  return true;
}

Future<void> saveRecord({
  required String destinationName,
  required double destinationLat,
  required double destinationLong,
  required double consideredDistance,
}) async {
  try {
    final db =
        await Hive.openBox<TravelEntity>(ConstantData.travelsDatabaseName);

    await db.add(TravelEntity(
      consideredDistance: consideredDistance,
      destinationName: destinationName,
      destinationLat: destinationLat,
      destinationLong: destinationLong,
      date: DateTime.now(),
    ));
    await db.close();
  } catch (e) {
    await NotificationUtils.showNotification(
        body: "Could not save the travel history: ${e.toString()}");
  }
}

Future<void> initDB() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TravelEntityAdapter());
}
