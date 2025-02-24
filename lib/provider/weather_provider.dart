import 'dart:convert';

import 'package:assignment_sm_api/models/current_weather.dart';
import 'package:assignment_sm_api/models/forecast_weather.dart';
import 'package:assignment_sm_api/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier {
  /*static const lat = 23.8238582;
  static const lng = 90.3661377;*/
  double _latitude = 0.0;
  double _longitude = 0.0;
  String unit = metric;
  CurrentWeather? currentWeather;
  ForecastWeather? forecastWeather;

  bool get hasDataLoaded => currentWeather != null &&
      forecastWeather != null;

  setNewLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
  }

  setTempUnit(bool tag) {
    unit = tag ? imperial : metric;
  }

  String get tempUnitSymbol => unit == metric ? celsius : fahrenheit;

  Future<String> convertCityToCoord(String city) async {
    try {
      final locationList = await locationFromAddress(city);
      if(locationList.isNotEmpty) {
        final location = locationList.first;
        setNewLocation(location.latitude, location.longitude);
        getData();
        return 'Fetching data for $city';
      } else {
        return 'Could not found location';
      }
    } catch (error) {
      return error.toString();
    }
  }

  getData() {
    _getCurrentData();
    _getForecastData();
  }

  Future<void> _getCurrentData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$_latitude&lon=$_longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        final map = json.decode(response.body);
        currentWeather = CurrentWeather.fromJson(map);
        print(currentWeather?.main?.temp);
        notifyListeners();
      } else {
        final map = json.decode(response.body);
        print(map['message']);
      }
    } catch(error) {
      print(error.toString());
    }
  }

  Future<void> _getForecastData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$_latitude&lon=$_longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        final map = json.decode(response.body);
        forecastWeather = ForecastWeather.fromJson(map);
        print(forecastWeather?.list?.length);
        notifyListeners();
      } else {
        final map = json.decode(response.body);
        print(map['message']);
      }
    } catch(error) {
      print(error.toString());
    }
  }
}