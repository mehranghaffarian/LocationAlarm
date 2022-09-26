import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_alarm/core/constant_data.dart';
import 'package:location_alarm/core/extensions/position_extenion.dart';
import 'package:location_alarm/core/position_utils.dart';
import 'package:location_alarm/presentation/pages/choose_destination/choose_destination_bloc.dart';
import 'package:location_alarm/presentation/widgets/custom_app_bar.dart';
import 'package:location_alarm/presentation/widgets/custom_drawer.dart';
import 'package:location_alarm/core/extensions/build_context_extension.dart';

class ChooseDestinationPage extends StatelessWidget {
  static const routeName = 'choose_destination_page';

  LatLng? destination;
  LatLng? userCurrLocation;
  final _mapController = MapController();
  final _bloc = ChooseDestinationBloc();

  ChooseDestinationPage({Key? key, this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const zoom = 14.0;

    PositionUtils.getCurrentPosition().then(
      (value) {
        if (value != null) {
          userCurrLocation = value.equivalentLatLng;

          _bloc.add(ChooseDestinationEvent(
            userCurrLocation: value.equivalentLatLng,
            preSetDestination: destination,
          ));
        }
      },
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(destination);
        return false;
      },
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: CustomAppBar(
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.cancel_sharp,
              color: theme.errorColor,
              size: 30,
            ),
          ),
          actions: [
            InkWell(
              child: Container(
                margin: const EdgeInsets.all(15),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: () {
                if (destination != null) {
                  Navigator.of(context).pop(destination);
                } else {
                  context.showSnack(
                      'Please select the destination first', theme.errorColor);
                }
              },
            ),
          ],
          title: 'Choose Your Destination',
        ),
        body: BlocBuilder<ChooseDestinationBloc, ChooseDestinationState>(
          bloc: _bloc,
          builder: (context, state) {
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onLongPress: (tapPosition, point) {
                  destination = point;
                  _bloc.add(ChooseDestinationEvent(destination: point));
                },
                center: destination ??
                    userCurrLocation ??
                        ConstantData.AUTLatLng,
                zoom: (destination == null && userCurrLocation == null) ? 10 : zoom,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.location_alarm.app',
                ),
                MarkerLayerOptions(
                  markers: [
                    if (destination != null)
                      Marker(
                        point: destination!,
                        builder: (_) => Icon(
                          Icons.location_on_sharp,
                          color: theme.errorColor,
                          size: 30,
                        ),
                      ),
                    if (state.attributes.userCurrLocation != null)
                      Marker(
                        point: state.attributes.userCurrLocation!,
                        builder: (_) => Container(
                          width: 30,
                          decoration: ShapeDecoration(
                            color: theme.primaryColor,
                            shape: const CircleBorder(),
                            shadows: [
                              BoxShadow(
                                color: theme.backgroundColor,
                                blurRadius: 15,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  rotate: true,
                ),
              ],
              nonRotatedChildren: [
                InkWell(
                  onTap: () => PositionUtils.getCurrentPosition().then((value) {
                    if (value != null) {
                      _mapController.move(
                        value.equivalentLatLng,
                        zoom,
                      );
                      _bloc.add(ChooseDestinationEvent(
                          userCurrLocation: value.equivalentLatLng));
                    }
                  }),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
                        width: 20,
                        margin: const EdgeInsets.all(15),
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          shadows: [
                            BoxShadow(
                              color: theme.backgroundColor,
                              blurRadius: 10,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location_outlined,
                          color: theme.primaryColorDark,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                AttributionWidget.defaultWidget(
                  alignment: Alignment.bottomLeft,
                  source: 'OpenStreetMap',
                  onSourceTapped: null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
