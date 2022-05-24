import '../../flutter_polyline_points.dart';
import 'leg.dart';

/// description:
/// project: flutter_polyline_points
/// @package:
/// @author: dammyololade
/// created on: 13/05/2020
class PolylineResult {
  /// the api status retuned from google api
  ///
  /// returns OK if the api call is successful
  String? status;

  /// list of decoded points
  List<PointLatLng> points;

  List<Leg> legs;

  List<int> waypointOrder;

  int getRouteTimeSeconds() {
    int total = 0;
    legs.forEach((element) {
      total += element.duration ?? 0;
    });
    return total;
  }

  /// the error message returned from google, if none, the result will be empty
  String? errorMessage;

  PolylineResult(
      {this.status,
      this.points = const [],
      this.legs = const [],
      this.waypointOrder = const [],
      this.errorMessage = ""});
}
