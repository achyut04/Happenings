import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/place_from_coordinates.dart';  // Your model for PlaceFromCoordinates
import 'package:my_app/get_places.dart';

class ApiServices {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _gcpKey = 'AIzaSyBLNERzXQj0brI3aiIr16DLXHAoy_Ggujo'; // Replace with your actual API key

  // Get place predictions based on user input
  Future<GetPlaces> getPlaces(String placeName) async {
    // Construct the API request URL for Google Places Autocomplete API
    final Uri url = Uri.parse(
      '$_baseUrl/autocomplete/json?input=$placeName&key=$_gcpKey'
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Parse the JSON response
        return GetPlaces.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load place predictions');
      }
    } catch (error) {
      throw Exception('API ERROR: $error');
    }
  }

  // Get coordinates from a place's latitude and longitude
  Future<PlaceFromCoordinates> placeFromCoordinates(double lat, double lng) async {
    // Construct the API request URL for Google Reverse Geocoding API
    final Uri url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_gcpKey'
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Parse the JSON response
        return PlaceFromCoordinates.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load coordinates');
      }
    } catch (error) {
      throw Exception('API ERROR: $error');
    }
  }
}
