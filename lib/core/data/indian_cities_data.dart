/// Database of major Indian cities with their coordinates
class IndianCitiesData {
  static final List<CityLocation> cities = [
    // Metro Cities
    CityLocation(name: 'Mumbai', state: 'Maharashtra', latitude: 19.0760, longitude: 72.8777),
    CityLocation(name: 'Delhi', state: 'Delhi', latitude: 28.7041, longitude: 77.1025),
    CityLocation(name: 'Bangalore', state: 'Karnataka', latitude: 12.9716, longitude: 77.5946),
    CityLocation(name: 'Kolkata', state: 'West Bengal', latitude: 22.5726, longitude: 88.3639),
    CityLocation(name: 'Chennai', state: 'Tamil Nadu', latitude: 13.0827, longitude: 80.2707),
    CityLocation(name: 'Hyderabad', state: 'Telangana', latitude: 17.3850, longitude: 78.4867),
    
    // Tier 1 Cities
    CityLocation(name: 'Pune', state: 'Maharashtra', latitude: 18.5204, longitude: 73.8567),
    CityLocation(name: 'Ahmedabad', state: 'Gujarat', latitude: 23.0225, longitude: 72.5714),
    CityLocation(name: 'Jaipur', state: 'Rajasthan', latitude: 26.9124, longitude: 75.7873),
    CityLocation(name: 'Surat', state: 'Gujarat', latitude: 21.1702, longitude: 72.8311),
    CityLocation(name: 'Lucknow', state: 'Uttar Pradesh', latitude: 26.8467, longitude: 80.9462),
    CityLocation(name: 'Kanpur', state: 'Uttar Pradesh', latitude: 26.4499, longitude: 80.3319),
    CityLocation(name: 'Nagpur', state: 'Maharashtra', latitude: 21.1458, longitude: 79.0882),
    CityLocation(name: 'Indore', state: 'Madhya Pradesh', latitude: 22.7196, longitude: 75.8577),
    CityLocation(name: 'Thane', state: 'Maharashtra', latitude: 19.2183, longitude: 72.9781),
    CityLocation(name: 'Bhopal', state: 'Madhya Pradesh', latitude: 23.2599, longitude: 77.4126),
    CityLocation(name: 'Visakhapatnam', state: 'Andhra Pradesh', latitude: 17.6868, longitude: 83.2185),
    CityLocation(name: 'Patna', state: 'Bihar', latitude: 25.5941, longitude: 85.1376),
    
    // Tier 2 Cities
    CityLocation(name: 'Vadodara', state: 'Gujarat', latitude: 22.3072, longitude: 73.1812),
    CityLocation(name: 'Ghaziabad', state: 'Uttar Pradesh', latitude: 28.6692, longitude: 77.4538),
    CityLocation(name: 'Ludhiana', state: 'Punjab', latitude: 30.9010, longitude: 75.8573),
    CityLocation(name: 'Agra', state: 'Uttar Pradesh', latitude: 27.1767, longitude: 78.0081),
    CityLocation(name: 'Nashik', state: 'Maharashtra', latitude: 19.9975, longitude: 73.7898),
    CityLocation(name: 'Faridabad', state: 'Haryana', latitude: 28.4089, longitude: 77.3178),
    CityLocation(name: 'Meerut', state: 'Uttar Pradesh', latitude: 28.9845, longitude: 77.7064),
    CityLocation(name: 'Rajkot', state: 'Gujarat', latitude: 22.3039, longitude: 70.8022),
    CityLocation(name: 'Varanasi', state: 'Uttar Pradesh', latitude: 25.3176, longitude: 82.9739),
    CityLocation(name: 'Srinagar', state: 'Jammu & Kashmir', latitude: 34.0837, longitude: 74.7973),
    CityLocation(name: 'Amritsar', state: 'Punjab', latitude: 31.6340, longitude: 74.8723),
    CityLocation(name: 'Allahabad', state: 'Uttar Pradesh', latitude: 25.4358, longitude: 81.8463),
    CityLocation(name: 'Ranchi', state: 'Jharkhand', latitude: 23.3441, longitude: 85.3096),
    CityLocation(name: 'Howrah', state: 'West Bengal', latitude: 22.5958, longitude: 88.2636),
    CityLocation(name: 'Jabalpur', state: 'Madhya Pradesh', latitude: 23.1815, longitude: 79.9864),
    CityLocation(name: 'Gwalior', state: 'Madhya Pradesh', latitude: 26.2183, longitude: 78.1828),
    CityLocation(name: 'Vijayawada', state: 'Andhra Pradesh', latitude: 16.5062, longitude: 80.6480),
    CityLocation(name: 'Jodhpur', state: 'Rajasthan', latitude: 26.2389, longitude: 73.0243),
    CityLocation(name: 'Madurai', state: 'Tamil Nadu', latitude: 9.9252, longitude: 78.1198),
    CityLocation(name: 'Raipur', state: 'Chhattisgarh', latitude: 21.2514, longitude: 81.6296),
    CityLocation(name: 'Kota', state: 'Rajasthan', latitude: 25.2138, longitude: 75.8648),
    CityLocation(name: 'Chandigarh', state: 'Chandigarh', latitude: 30.7333, longitude: 76.7794),
    CityLocation(name: 'Guwahati', state: 'Assam', latitude: 26.1445, longitude: 91.7362),
    CityLocation(name: 'Mysore', state: 'Karnataka', latitude: 12.2958, longitude: 76.6394),
    CityLocation(name: 'Bareilly', state: 'Uttar Pradesh', latitude: 28.3670, longitude: 79.4304),
    CityLocation(name: 'Thiruvananthapuram', state: 'Kerala', latitude: 8.5241, longitude: 76.9366),
    CityLocation(name: 'Aligarh', state: 'Uttar Pradesh', latitude: 27.8974, longitude: 78.0880),
    CityLocation(name: 'Bhubaneswar', state: 'Odisha', latitude: 20.2961, longitude: 85.8245),
    CityLocation(name: 'Coimbatore', state: 'Tamil Nadu', latitude: 11.0168, longitude: 76.9558),
    CityLocation(name: 'Kochi', state: 'Kerala', latitude: 9.9312, longitude: 76.2673),
    CityLocation(name: 'Dehradun', state: 'Uttarakhand', latitude: 30.3165, longitude: 78.0322),
    CityLocation(name: 'Karwar', state: 'Karnataka', latitude: 14.8137, longitude: 74.1290),
    
    // Add more as needed
  ];

  static List<CityLocation> get sortedCities {
    final sorted = List<CityLocation>.from(cities);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  static CityLocation? findCity(String cityName) {
    final normalized = cityName.toLowerCase().trim();
    return cities.firstWhere(
      (city) => city.name.toLowerCase() == normalized,
      orElse: () => cities[1], // Default to Delhi
    );
  }
}

class CityLocation {
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final double timezone; // Timezone offset in hours (e.g., 5.5 for IST)

  CityLocation({
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5, // Default to IST
  });

  String get displayName => '$name, $state';
  
  @override
  String toString() => displayName;
}
