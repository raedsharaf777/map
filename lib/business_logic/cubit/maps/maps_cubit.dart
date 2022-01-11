import 'package:bloc/bloc.dart';
import 'package:maps/data/models/place.dart';
import 'package:maps/data/models/place_suggestion.dart';
import 'package:maps/data/repository/maps_repository.dart';
import 'package:meta/meta.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;

  MapsCubit(this.mapsRepository) : super(MapsInitial());

  void emitPlaceSuggestions(String place, String sessionToken) {
    mapsRepository.fetchSuggestions(place, sessionToken).then((suggestion) {
      emit(PlaceLoaded(suggestion));
    });
  }

  void emitPlaceLocation(String placeId, String sessionToken) {
    mapsRepository.getPlaceLocation(placeId, sessionToken).then((place) {
      emit(PlaceLocationLoaded(place));
    });
  }
}
