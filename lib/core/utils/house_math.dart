/// Simple house counting utility
class HouseMath {
  /// Count houses from a starting house
  /// 
  /// [fromHouse] - Starting house (1-12)
  /// [count] - Number of houses to count
  /// Returns: The resulting house number (1-12)
  static int countFrom(int fromHouse, int count) {
    final result = ((fromHouse - 1 + count) % 12) + 1;
    return result;
  }
}
