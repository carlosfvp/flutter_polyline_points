import '../../flutter_polyline_points.dart';

class Step {
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

  PointLatLng? startLocation;
  PointLatLng? endLocation;

  String? htmlInstructions;
  late List<PointLatLng> points;

  Step(
      {this.distance,
      this.distanceText,
      this.duration,
      this.durationText,
      this.startLocation,
      this.endLocation,
      this.htmlInstructions,
      this.points = const []});
}
