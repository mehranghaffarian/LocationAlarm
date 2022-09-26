import 'package:latlong2/latlong.dart';

class ChooseDestinationEntity {
  LatLng? preSetDestination;
  LatLng? destination;
  LatLng? userCurrLocation;

  ChooseDestinationEntity({
     this.preSetDestination,
     this.destination,
     this.userCurrLocation,
  });
}
