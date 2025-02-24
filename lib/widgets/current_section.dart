import 'package:assignment_sm_api/models/current_weather.dart';
import 'package:assignment_sm_api/utils/constants.dart';
import 'package:assignment_sm_api/utils/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CurrentSection extends StatelessWidget {
  final CurrentWeather currentWeather;
  final String unitSymbol;

  const CurrentSection({
    super.key,
    required this.currentWeather,
    required this.unitSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            getFormattedDateTime(currentWeather.dt!,
                pattern: 'EEE MMM dd, yyyy'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white54,
            ),
          ),
          Text(
            '${currentWeather.name!}-${currentWeather.sys!.country}',
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
          Text(
            '${currentWeather.main!.temp!.toStringAsFixed(0)}$degree$unitSymbol',
            style: const TextStyle(
              fontSize: 100,
            ),
          ),
          Text(
            'feels like ${currentWeather.main!.feelsLike!.toStringAsFixed(0)}$degree$unitSymbol',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          CachedNetworkImage(
            imageUrl:
                '$prefixWeatherIconUrl${currentWeather.weather![0].icon}$suffixWeatherIconUrl',
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          Text(
            currentWeather.weather![0].description!,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
