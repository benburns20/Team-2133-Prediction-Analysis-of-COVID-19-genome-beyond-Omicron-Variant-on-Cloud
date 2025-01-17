import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genome_2133/cards/country.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../home.dart';
import '../main.dart';
import "skeleton.dart";

Map<String, Widget> cache = {};

class ContinentCard extends StatefulWidget {
  final String continent;
  final LatLng _initMapCenter = const LatLng(20, 0);
  final Function updateParent;
  final GlobalKey<_ContinentCard> controlKey;

  const ContinentCard(
      {required this.continent,
      required this.updateParent,
        required this.controlKey})
      : super(key: controlKey);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return continent;
  }

  @override
  State<ContinentCard> createState() => _ContinentCard();

  void centerMap() {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(_initMapCenter, 3.2));
  }

  updateMap() async {
    if (isDesktop || isMapDisabled) return;

    final String response = await rootBundle.loadString('assets/data.json');
    final Map continents = await json.decode(response)["Continents"];
    final Map continentMap = continents[continent];
    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(
            continentMap["latitude"],
            continentMap["longitude"]),
        continentMap["zoom"].toDouble()));
  }
}

class _ContinentCard extends State<ContinentCard> {
  _updateMap() async {
    if (isDesktop || isMapDisabled) return;

    final String response = await rootBundle.loadString('assets/data.json');
    final Map continents = await json.decode(response)["Continents"];
    final Map continent = continents[widget.continent];
    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(
            continent["latitude"],
            continent["longitude"]),
        continent["zoom"].toDouble()));
  }

  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _updateMap();
  }

  Future<List<Map<String, dynamic>>> getContinent() async {
    var request = http.Request('GET',
        Uri.parse('https://restcountries.com/v3.1/all'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseDecoded = await response.stream.bytesToString();
      List<Map<String, dynamic>> decode = List<Map<String, dynamic>>.from(jsonDecode(responseDecoded));
      List<Map<String, dynamic>> output = [];
      for (Map<String, dynamic> country in decode) {
        if (country["continents"].contains(widget.continent)) {
          output.add(country);
        }
      }
      return output;
    }
    return [
      {"error": response.reasonPhrase}
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 12, left: 12),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  FutureBuilder(
                      future: getContinent(),
                      builder: (context, snapshot) {
                        return FutureBuilder(
                            future: rootBundle.loadString("assets/data.json"),
                            builder: (context, countrySnapshot) {
                              if (!snapshot.hasData || !countrySnapshot.hasData) {
                                if (cache.containsKey(widget.continent)) {
                                  return cache[widget.continent]!;
                                }
                                return Expanded(child: Center(
                                  child: CircularProgressIndicator(
                                    color:
                                    dict[theme].secondaryHeaderColor,
                                  ),
                                ),);
                              }

                              List countries = json.decode(countrySnapshot.data!
                                  .toString())["Countries"];
                              Map<String, List<String>> ordering = {};

                              for (Map<String, dynamic> country
                              in List.from(snapshot.data! as List)) {
                                for (Map<String, dynamic> storedCountry
                                in countries) { // belize exists in stored
                                  if (!storedCountry.containsKey("cca3")) {
                                    continue;
                                  }

                                  String key = country.containsKey("subregion") ? country["subregion"] : country["region"];
                                  if (country["cca3"] == storedCountry["cca3"]) {
                                    if (!ordering
                                        .containsKey(key)) {
                                      ordering[key] = [];
                                    }
                                    ordering[key]!
                                        .add(storedCountry["country"]);
                                    break;
                                  }
                                }
                              }

                              Map<String, dynamic> getCountry (String name) {
                                for (Map<String, dynamic> country
                                in countries) {
                                  if (name == country["country"]) {
                                    return country;
                                  }
                                }
                                return {};
                              }

                              List<Widget> output = [];
                              for (String region in ordering.keys) {
                                output.add(Padding(
                                  padding:
                                      EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text(region,
                                      style: TextStyle(fontSize: 18, color: dict[theme].primaryColor)),
                                ));

                                ordering[region]!.sort();

                                for (String country in ordering[region]!) {
                                  output.add(Align(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      child: Text(
                                        country,
                                        style: TextStyle(
                                          color: dict[theme]
                                              .highlightColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      onTap: () {
                                        addCard(SkeletonCard(
                                          controlKey: GlobalKey(),
                                          updateParent: widget.updateParent,
                                          title: country,
                                          body: CountryCard(
                                            country: getCountry(country),
                                            updateParent: widget.updateParent,
                                            controlKey: GlobalKey(),
                                          ),
                                        ));
                                        widget.updateParent();
                                      },
                                    ),
                                  ));
                                }
                              }
                              output.add(Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(),
                              ));

                              cache[widget.continent] = Column(
                                children: output,
                              );
                              return cache[widget.continent]!;
                            });
                      })
                ],
              ),
            )
          ],
        ));
  }
}
