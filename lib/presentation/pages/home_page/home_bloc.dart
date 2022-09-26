import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';

class HomeBloc extends Bloc<LaEvent, LAState> {
  HomeBloc() : super(InitialState()) {
    on<DestinationSetEvent>((event, emit) {
      emit(DestinationSetState(event.destination));
    });
  }
}

abstract class LaEvent {}

class DestinationSetEvent extends LaEvent {
  final LatLng destination;

  DestinationSetEvent(this.destination);
}

abstract class LAState {}

class InitialState extends LAState {}

class DestinationSetState extends LAState {
  final LatLng destination;

  DestinationSetState(this.destination);
}
