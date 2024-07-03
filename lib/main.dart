import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meteo/models/meteodata.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp(
    config: {},
  ));
}

class MyApp extends StatelessWidget {
  final Map<String, String> config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(config: config),
    );
  }
}

class HomePage extends StatefulWidget {
  final Map<String, String> config;

  const HomePage({super.key, required this.config});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _cityController = TextEditingController();
  Future<MeteoData>? _weather;
  String? _errorMessage;
  LatLng? _cityCoordinates;
  GoogleMapController? _mapController;

  void _searchWeather() {
    setState(() {
      _errorMessage = null;
      _weather = _fetchWeather();
    });
  }

  Future<MeteoData> _fetchWeather() async {
    try {
      final coords = await MeteoData.getCoordinates(_cityController.text);
      setState(() {
        _cityCoordinates = LatLng(coords['lat']!, coords['lon']!);
      });
      return await MeteoData.getWeather(coords['lat']!, coords['lon']!);
    } catch (error) {
      setState(() {
        _errorMessage = "La ville n'existe pas";
      });
      rethrow;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appli météo')),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Entrez le nom de la ville',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchWeather,
              child: const Text('Recherche'),
            ),
            const SizedBox(height: 20),
            _weather == null
                ? Container()
                : FutureBuilder<MeteoData>(
                    future: _weather,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No data');
                      } else {
                        return Column(
                          children: [
                            Text(
                                'City: ${snapshot.data!.cityName}, ${snapshot.data!.country}'),
                            Text(
                                'Temperature: ${snapshot.data!.temperature}°C'),
                            const SizedBox(height: 20),
                            //_cityCoordinates == null
                            // ? Container()
                            // : Expanded(
                            //     child: SizedBox(
                            //       width: double.infinity,
                            //       height: 400.0,
                            //       child: GoogleMap(
                            //         onMapCreated: _onMapCreated,
                            //         initialCameraPosition: CameraPosition(
                            //           target: _cityCoordinates!,
                            //           zoom: 13.0,
                            //         ),
                            //         markers: _cityCoordinates == null
                            //             ? <Marker>{}
                            //             : {
                            //                 Marker(
                            //                   markerId: const MarkerId(
                            //                       "cityMarker"),
                            //                   position: _cityCoordinates!,
                            //                   infoWindow: InfoWindow(
                            //                     title:
                            //                         snapshot.data!.cityName,
                            //                     snippet:
                            //                         "Temperature: ${snapshot.data!.temperature}°C",
                            //                   ),
                            //                 )
                            //               },
                            //       ),
                            //     ),
                            //   ),
                          ],
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
