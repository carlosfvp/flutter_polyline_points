import '../../flutter_polyline_points.dart';
import 'step.dart';

/// description:
/// project: flutter_polyline_points
/// @package:
/// @author: carlosfvp
/// created on: 19/05/2022
class Leg {
  /// the api status retuned from google api
  ///
  /// distance in meters
  int? distance;
  // display text in preffered units from Google account
  String? distanceText;

  // duration in seconds
  int? duration;
  // duration description
  String? durationText;

  String? startAddress;
  PointLatLng? startLocation;

  String? endAddress;
  PointLatLng? endLocation;

  List<Step> steps;

  Leg(
      {this.distance,
      this.distanceText,
      this.duration,
      this.durationText,
      this.startAddress,
      this.startLocation,
      this.endAddress,
      this.endLocation,
      this.steps = const []});
}
