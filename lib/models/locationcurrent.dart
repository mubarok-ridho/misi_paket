class UserLocation {
  final String name;
  final double lat;
  final double lng;

  UserLocation({required this.name, required this.lat, required this.lng});

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "lng": lng,
  };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
    name: json["name"],
    lat: json["lat"],
    lng: json["lng"],
  );
}
