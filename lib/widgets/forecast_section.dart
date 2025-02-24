import 'package:assignment_sm_api/utils/constants.dart';
import 'package:assignment_sm_api/utils/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/forecast_weather.dart';

class ForecastSection extends StatelessWidget {
  final List<ForecastItem> items;

  const ForecastSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return AspectRatio(
            aspectRatio: 0.8,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Card(
                color: cardBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      Text(getFormattedDateTime(
                        item.dt!,
                        pattern: 'EEE HH:mm',
                      )),
                      Text(
                        '${item.main!.tempMax!.round()}/${item.main!.tempMin!.round()}$degree',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl:
                              '$prefixWeatherIconUrl${item.weather![0].icon}$suffixWeatherIconUrl',
                          width: 50,
                          height: 50,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Text(
                        item.weather![0].description!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
