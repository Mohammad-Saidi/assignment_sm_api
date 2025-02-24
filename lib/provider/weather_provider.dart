import 'dart:async';
import 'dart:convert';
import 'package:assignment_sm_api/models/current_weather.dart';
import 'package:assignment_sm_api/models/forecast_weather.dart';
import 'package:assignment_sm_api/utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


class WeatherProvider extends ChangeNotifier {

  bool _isConnected = true;
  bool _isLocationEnabled = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool get isConnected => _isConnected;
  bool get isLocationEnabled => _isLocationEnabled;

  WeatherProvider() {
    _checkInternetConnection();
    //_checkLocationStatus();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _isConnected = results.any((result) => result != ConnectivityResult.none);
      notifyListeners();
    });

  }

  Future<void> _checkInternetConnection() async {
    var result = await _connectivity.checkConnectivity();
    _isConnected = result.any((result) => result != ConnectivityResult.none);
    notifyListeners();
  }

  // Future<void> _checkLocationStatus() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   LocationPermission permission = await Geolocator.checkPermission();
  //
  //   if (!serviceEnabled || permission == LocationPermission.deniedForever) {
  //     _isLocationEnabled = false;
  //   } else {
  //     _isLocationEnabled = true;
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       _isLocationEnabled = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  //     }
  //   }
  //   notifyListeners();
  //
  // }



  @override
  void dispose() {
    // TODO: implement dispose
    _subscription.cancel();
    super.dispose();
  }





  final _weatherBox = Hive.box('weather');
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
        await _weatherBox.put('currentData', map);
        currentWeather = CurrentWeather.fromJson(map);
        print(currentWeather?.main?.temp);
        notifyListeners();
      } else {
        final map = json.decode(response.body);
        print(map['message']);
      }
    } catch(error) {

      final map = _weatherBox.get('currentData');
      currentWeather = CurrentWeather.fromJson(map);
      notifyListeners();
      if (currentWeather == null) throw Exception('No internet connection and no cached data available');


      print(error.toString());
    }
  }

  Future<void> _getForecastData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$_latitude&lon=$_longitude&units=$unit&appid=$weatherApiKey');
    try {
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        final map = json.decode(response.body);
        await _weatherBox.put('forecastData', map);
        forecastWeather = ForecastWeather.fromJson(map);
        print(forecastWeather?.list?.length);
        notifyListeners();
      } else {
        final map = json.decode(response.body);
        print(map['message']);
      }
    } catch(error) {

      final map = _weatherBox.get('forecastData');
      forecastWeather = ForecastWeather.fromJson(map);
      notifyListeners();

      if (forecastWeather == null) {
        throw Exception('No internet connection and no cached data available');
      }


      print(error.toString());
    }
  }
}