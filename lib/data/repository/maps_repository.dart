import 'package:maps/data/models/place.dart';
import 'package:maps/data/models/place_suggestion.dart';
import 'package:maps/data/webservices/place_web_services.dart';

class MapsRepository {
  final PlaceWebServices placeWebServices;

  MapsRepository(this.placeWebServices);

  Future<List<PlaceSuggestion>> fetchSuggestions(
      String place, String sessionToken) async {
    final suggestion =
        await placeWebServices.fetchSuggestions(place, sessionToken);
    return suggestion
        .map((suggestion) => PlaceSuggestion.fromJson(suggestion))
        .toList();
  }

  Future<Place> getPlaceLocation(String placeId, String sessionToken) async {
    final place =
        await placeWebServices.getPlaceLocation(placeId, sessionToken);
    return Place.fromJson(place);
  }
}
