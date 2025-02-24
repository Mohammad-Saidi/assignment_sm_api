import 'package:assignment_sm_api/pages/settings.dart';
import 'package:assignment_sm_api/utils/helper.dart';
import 'package:assignment_sm_api/utils/location_service.dart';
import 'package:assignment_sm_api/widgets/current_section.dart';
import 'package:assignment_sm_api/widgets/forecast_section.dart';
import 'package:assignment_sm_api/widgets/parallax_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/weather_provider.dart';
import '../utils/constants.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late WeatherProvider provider;



  @override
  void didChangeDependencies() {
    provider = Provider.of<WeatherProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivity(context);
    });
    getLocation();
    super.didChangeDependencies();
  }

  void _checkConnectivity(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    if (!provider.isConnected) {
      _showNoInternetDialog(context, "No Internet Connection! Please check your network");
    }
    // if (!provider.isLocationEnabled) {
    //   _showNoLocationDialog(context, "Location services are off, please enable GPS");
    // }
  }

  void _showNoInternetDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        //title: const Text("No Internet Connection"),
        content:
            Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivity(context);
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void _showNoLocationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        //title: const Text("No Internet Connection"),
        content:
        Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  getLocation() async {
    final position = await determinePosition();
    provider.setNewLocation(position.latitude, position.longitude);
    provider.setTempUnit(await getTempStatus());
    provider.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNoInternetDialog(context, "No Internet Connection! Please check your network.");
          });
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text('Daily Weather'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: _CitySearchDelegate(),
                  ).then((value) {
                    if (value != null && value.isNotEmpty) {
                      provider.convertCityToCoord(value).then((value) {
                        print(value);
                        showMsg(context, value);
                      });
                    }
                  });
                },
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  getLocation();
                },
                icon: const Icon(Icons.my_location),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: provider.hasDataLoaded && provider.isConnected
              ? Stack(
                  children: [
                    ParallaxBackground(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CurrentSection(
                          currentWeather: provider.currentWeather!,
                          unitSymbol: provider.tempUnitSymbol,
                        ),
                        ForecastSection(items: provider.forecastWeather!.list!),
                      ],
                    ),
                  ],
                )
              : (!provider.isConnected)
                  ? Center(child: const Text("No Internet Connection"))
                  : const Center(
                      child: Text('Please wait'),
                    ),
        );
      },
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      title: Text(query),
      leading: const Icon(Icons.search),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities.where((city) => city.toLowerCase().startsWith(query)).toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          close(context, filteredList[index]);
        },
        title: Text(filteredList[index]),
      ),
    );
  }
}
