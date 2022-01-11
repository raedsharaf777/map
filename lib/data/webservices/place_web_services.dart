import 'package:dio/dio.dart';
import 'package:maps/constants/strings.dart';
import 'package:maps/data/models/place_suggestion.dart';

class PlaceWebServices {
  late Dio dio;

  PlaceWebServices() {
    BaseOptions options = BaseOptions(
      receiveDataWhenStatusError: true,
      connectTimeout: 20 * 1000,
      receiveTimeout: 20 * 1000,
    );
    dio = Dio(options);
  }

  Future<List<dynamic>> fetchSuggestions(
      String place, String sessionToken) async {
    try {
      Response response = await dio.get(
        suggestionBaseUrl,
        queryParameters: {
          'input': place,
          'type': 'address',
          'components': 'country:eg',
          'key': googleAPIKEY,
          'sessiontoken': sessionToken,
        },
      );

      print(response.data['predictions']);
      print(response.statusCode);
      return response.data['predictions'];
    } catch (error) {
      print("the error of response ${error.toString()}");
      return [];
    }
  }

  Future<dynamic> getPlaceLocation(String placeId, String sessionToken) async {
    try {
      Response response = await dio.get(
        placeLocationBaseUrl,
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': googleAPIKEY,
          'sessiontoken': sessionToken,
        },
      );
      return response.data;
    } catch (error) {
      return Future.error('Place Location Error : ',
          StackTrace.fromString('this is its trace'));
    }
  }
}
