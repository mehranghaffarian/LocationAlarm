import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_alarm/domain/entities/choose_destination_Entity.dart';

class ChooseDestinationBloc
    extends Bloc<ChooseDestinationEvent, ChooseDestinationState> {
  final pageAttributes = ChooseDestinationEntity();

  ChooseDestinationBloc()
      : super(ChooseDestinationState(ChooseDestinationEntity())) {
    on<ChooseDestinationEvent>(
      (event, emit) {
        pageAttributes.preSetDestination =
            event.preSetDestination ?? pageAttributes.preSetDestination;
        pageAttributes.destination =
            event.destination ?? pageAttributes.destination;
        pageAttributes.userCurrLocation =
            event.userCurrLocation ?? pageAttributes.userCurrLocation;

         emit(
          ChooseDestinationState(pageAttributes),
        );
      },
    );
  }
}

class ChooseDestinationEvent {
  LatLng? preSetDestination;
  LatLng? destination;
  LatLng? userCurrLocation;

  ChooseDestinationEvent({
    this.preSetDestination,
    this.destination,
    this.userCurrLocation,
  });
}

class ChooseDestinationState {
  final ChooseDestinationEntity attributes;

  ChooseDestinationState(this.attributes);
}
