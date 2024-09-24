import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/place_from_coordinates.dart';
import 'package:my_app/get_places.dart';

class ApiServices {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _gcpKey = 'AIzaSyBLNERzXQj0brI3aiIr16DLXHAoy_Ggujo';

  Future<GetPlaces> getPlaces(String placeName) async {
    final Uri url =
        Uri.parse('$_baseUrl/autocomplete/json?input=$placeName&key=$_gcpKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return GetPlaces.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load place predictions');
      }
    } catch (error) {
      throw Exception('API ERROR: $error');
    }
  }

  Future<PlaceFromCoordinates> placeFromCoordinates(
      double lat, double lng) async {
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_gcpKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return PlaceFromCoordinates.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load coordinates');
      }
    } catch (error) {
      throw Exception('API ERROR: $error');
    }
  }
}
