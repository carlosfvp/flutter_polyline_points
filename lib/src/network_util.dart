import 'dart:convert';

import 'package:http/http.dart' as http;

import '../src/PointLatLng.dart';
import '../src/utils/polyline_waypoint.dart';
import '../src/utils/request_enums.dart';
import 'utils/leg.dart';
import 'utils/polyline_result.dart';
import 'utils/step.dart';

class NetworkUtil {
  static const String STATUS_OK = "ok";

  ///Get the encoded string from google directions api
  ///
  Future<PolylineResult> getRouteBetweenCoordinates(
      String googleApiKey,
      PointLatLng origin,
      PointLatLng destination,
      TravelMode travelMode,
      List<PolylineWayPoint> wayPoints,
      bool avoidHighways,
      bool avoidTolls,
      bool avoidFerries,
      bool optimizeWaypoints) async {
    String mode = travelMode.toString().replaceAll('TravelMode.', '');
    PolylineResult result = PolylineResult();
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": mode,
      "avoidHighways": "$avoidHighways",
      "avoidFerries": "$avoidFerries",
      "avoidTolls": "$avoidTolls",
      "key": googleApiKey
    };
    if (wayPoints.isNotEmpty) {
      List wayPointsArray = [];
      wayPoints.forEach((point) => wayPointsArray.add(point.location));
      String wayPointsString = wayPointsArray.join('|');
      if (optimizeWaypoints) {
        wayPointsString = 'optimize:true|$wayPointsString';
      }
      params.addAll({"waypoints": wayPointsString});
    }
    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    // print('GOOGLE MAPS URL: ' + url);
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      result.status = parsedJson["status"];
      if (parsedJson["status"]?.toLowerCase() == STATUS_OK &&
          parsedJson["routes"] != null &&
          parsedJson["routes"].isNotEmpty) {
        result.points = decodeEncodedPolyline(
            parsedJson["routes"][0]["overview_polyline"]["points"]);

        List<dynamic> wpOrder =
            parsedJson["routes"][0]["waypoint_order"] as List<dynamic>;
        result.waypointOrder = wpOrder.map((e) {
          print(e);
          return e as int;
        }).toList();

        List<dynamic> legs = parsedJson["routes"][0]["legs"] as List<dynamic>;
        result.legs = legs.map((l) {
          Leg leg = new Leg(
              distance: l["distance"]["value"] as int,
              distanceText: l["distance"]["text"] as String,
              duration: l["duration"]["value"],
              durationText: l["duration"]["text"],
              startAddress: l["start_address"],
              startLocation: new PointLatLng(
                  l["start_location"]["lat"], l["start_location"]["lng"]),
              endAddress: l["end_address"],
              endLocation: new PointLatLng(
                  l["end_location"]["lat"], l["start_location"]["lng"]));
          List<dynamic> steps = l["steps"] as List<dynamic>;

          leg.steps = steps.map(
            (s) {
              Step step = new Step(
                  distance: s["distance"]["value"] as int,
                  distanceText: s["distance"]["text"] as String,
                  duration: s["duration"]["value"],
                  durationText: s["duration"]["text"],
                  startLocation: new PointLatLng(
                      s["start_location"]["lat"], s["start_location"]["lng"]),
                  endLocation: new PointLatLng(
                      s["end_location"]["lat"], s["start_location"]["lng"]),
                  htmlInstructions: s["html_instructions"],
                  points: decodeEncodedPolyline(s["polyline"]["points"]));
              return step;
            },
          ).toList();

          return leg;
        }).toList();
      } else {
        result.errorMessage = parsedJson["error_message"];
      }
    }
    return result;
  }

  ///decode the google encoded string using Encoded Polyline Algorithm Format
  /// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ///
  ///return [List]
  List<PointLatLng> decodeEncodedPolyline(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      PointLatLng p =
          new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
