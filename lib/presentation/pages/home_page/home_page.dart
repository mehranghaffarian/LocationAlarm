import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_alarm/core/background_service_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_alarm/core/constant_data.dart';
import 'package:location_alarm/core/extensions/build_context_extension.dart';
import 'package:location_alarm/core/notification_utils.dart';
import 'package:location_alarm/domain/entities/travel/travel_entity.dart';
import 'package:location_alarm/presentation/pages/home_page/home_bloc.dart';
import 'package:location_alarm/presentation/pages/choose_destination/choose_destination_page.dart';
import 'package:location_alarm/presentation/widgets/custom_app_bar.dart';
import 'package:location_alarm/presentation/widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  static const routeName = 'home_page';

  LatLng? destination;
  final _bloc = HomeBloc();
  final latController = TextEditingController();
  final longController = TextEditingController();
  final distanceController = TextEditingController();
  final destinationName = TextEditingController();

  HomePage({Key? key}) : super(key: key);

  bool get tripIsValid =>
      double.tryParse(latController.text) != null &&
      double.tryParse(longController.text) != null &&
      double.tryParse(distanceController.text) != null;

  @override
  Widget build(context) {
    distanceController.text = (1000.0).toString();
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(
        actions: [
          _buildChooseDestinationIcon(context: context),
        ],
        title: 'Location Alarm',
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<HomeBloc, LAState>(
                bloc: _bloc,
                builder: (_, state) {
                  if (destination != null) {
                    latController.text = destination!.latitude.toString();
                    return _buildTextField(
                      hintText: 'destination latitude',
                      labelText: 'Latitude',
                      controller: latController,
                      primaryColor: theme.primaryColor,
                    );
                  } else {
                    return _buildChooseDestinationIcon(
                      size: 40,
                      context: context,
                      color: theme.primaryColor,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<HomeBloc, LAState>(
                bloc: _bloc,
                builder: (_, state) {
                  if (destination != null) {
                    longController.text = destination!.longitude.toString();
                    return _buildTextField(
                      hintText: 'destination longitude',
                      labelText: 'Longitude',
                      controller: longController,
                      primaryColor: theme.primaryColor,
                      borderColor: state is DestinationSetState
                          ? Colors.green
                          : Colors.blueGrey,
                    );
                  } else {
                    return Text(
                      'Choose destination',
                      style: theme.textTheme.titleMedium,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Considered distance',
                labelText: 'Distance(m)',
                controller: distanceController,
                primaryColor: theme.primaryColor,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: 'Please enter the destination name',
                labelText: 'Destination Name',
                controller: destinationName,
                primaryColor: theme.primaryColor,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(theme.primaryColor),
                    ),
                    onPressed: () async {
                      if (tripIsValid) {
                        final service =
                            BackgroundServiceUtils.instance.backService;
                        final trip = TravelEntity(
                          destinationName: destinationName.text.isEmpty
                              ? 'unknown destination'
                              : destinationName.text,
                          destinationLat: double.parse(latController.text),
                          destinationLong: double.parse(longController.text),
                          consideredDistance:
                              double.tryParse(distanceController.text) ??
                                  1000.0,
                          date: DateTime.now(),
                        );

                        if (!(await BackgroundServiceUtils
                            .instance.isTracingTravel)) {
                          if (!(await service.isRunning())) {
                            await service.startService();

                            context.showSnack(
                              'Your trip will be registered soon',
                              theme.backgroundColor,
                            );
                            _registerTrip(
                              trip,
                              service,
                            );
                          } else {
                            service
                                .invoke(ConstantData.chasingLocationTaskName, {
                              ConstantData.destinationLatKey:
                                  trip.destinationLat,
                              ConstantData.destinationLongKey:
                                  trip.destinationLong,
                              ConstantData.destinationNameKey:
                                  trip.destinationName,
                              ConstantData.tripDistanceKey:
                                  trip.consideredDistance,
                            });
                          }
                        } else {
                          NotificationUtils.showNotification(
                              body:
                                  'you have a registered trip first cancel it');
                        }
                      } else {
                        context.showSnack(
                          "Please enter the attributes properly",
                          theme.errorColor,
                        );
                      }
                    },
                    child: const Text(
                      'Set Timer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(theme.errorColor)),
                    onPressed: () async {
                      final service =
                          BackgroundServiceUtils.instance.backService;

                      await BackgroundServiceUtils.instance.setIsTracingTravel(false);
                      if (await service.isRunning()) {
                        service.invoke(ConstantData.cancelTrip);
                      } else {
                        NotificationUtils.showNotification(
                            body: 'there is no trip in background');
                      }
                    },
                    child: const Text('Cancel trips',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required Color primaryColor,
    required String labelText,
    required TextEditingController controller,
    Color borderColor = Colors.blueGrey,
    TextInputType? keyboardType,
  }) =>
      TextField(
        cursorColor: primaryColor,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38),
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            gapPadding: 2,
          ),
        ),
        controller: controller,
        keyboardType: keyboardType ??
            const TextInputType.numberWithOptions(decimal: true),
      );

  _buildChooseDestinationIcon({
    required BuildContext context,
    Color? color,
    double? size,
  }) =>
      IconButton(
        onPressed: () async {
          final chosenDestination = await showGeneralDialog(
            context: context,
            pageBuilder: (_, __, ___) =>
                ChooseDestinationPage(destination: destination),
          );

          if (chosenDestination is LatLng) {
            destination = chosenDestination;
            _bloc.add(DestinationSetEvent(chosenDestination));

            Future.delayed(
              const Duration(milliseconds: 500),
              () => context.showSnack(
                'Destination set successfully',
                Theme.of(context).backgroundColor,
              ),
            );
          }
        },
        icon: Icon(
          Icons.add_location_outlined,
          color: color,
          size: size,
        ),
      );

  _registerTrip(TravelEntity trip, FlutterBackgroundService service) {
    Timer? tripTimer;

    tripTimer = Timer(const Duration(seconds: 3), () async {
      if (!(await BackgroundServiceUtils.instance.isTracingTravel) ) {
        if(await BackgroundServiceUtils.instance.backService.isRunning()){
          service.invoke(ConstantData.chasingLocationTaskName, {
            ConstantData.destinationLatKey: trip.destinationLat,
            ConstantData.destinationLongKey: trip.destinationLong,
            ConstantData.destinationNameKey: trip.destinationName,
            ConstantData.tripDistanceKey: trip.consideredDistance,
          });
          tripTimer!.cancel();
        }
      }else {
        NotificationUtils.showNotification(
            body:
            'you have a registered trip first cancel it');
      }
      if ((tripTimer?.tick ?? 4) >= 4) {
        NotificationUtils.showNotification(
            body: 'could not register your trip?!');
        tripTimer?.cancel();
      }
    });
  }
}
