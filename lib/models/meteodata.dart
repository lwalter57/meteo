import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MeteoData {
  final double temperature;
  final String cityName;
  final String country;

  MeteoData(
      {required this.temperature,
      required this.cityName,
      required this.country});

  factory MeteoData.fromJson(Map<String, dynamic> json) {
    return MeteoData(
      temperature: json['main']['temp'],
      cityName: json['name'],
      country: json['sys']['country'],
    );
  }

  static Future<Map<String, double>> getCoordinates(String cityName) async {
    var dio = Dio();
    var response = await dio.get(
      'https://api.api-ninjas.com/v1/city?name=$cityName',
      options: Options(headers: {'X-Api-Key': dotenv.env['CITY_API_KEY']}),
    );
    var data = response.data[0];
    return {'lat': data['latitude'], 'lon': data['longitude']};
  }

  static Future<MeteoData> getWeather(double lat, double lon) async {
    var dio = Dio();
    var response = await dio.get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': dotenv.env['METEO_API_KEY'],
        'units': 'metric',
      },
    );
    return MeteoData.fromJson(response.data);
  }
}
