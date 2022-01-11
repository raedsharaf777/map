part of 'maps_cubit.dart';

@immutable
abstract class MapsState {}

class MapsInitial extends MapsState {}

class PlaceLoaded extends MapsState {
  final List<PlaceSuggestion> places;

  PlaceLoaded(this.places);
}

class PlaceLocationLoaded extends MapsState {
  final Place place;

  PlaceLocationLoaded(this.place);
}
