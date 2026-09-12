/// Puzzle-number and date utilities shared across all games.
abstract final class DateService {
  /// The epoch date from which puzzle numbers are counted.
  static final DateTime _epoch = DateTime.utc(2025, 1, 1);

  /// Returns today's puzzle number (days since epoch, 0-indexed).
  static int puzzleNumber() {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return today.difference(_epoch).inDays;
  }

  /// Returns midnight of the current local day.
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Formats a date as YYYY-MM-DD for use as a storage key.
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';

  /// Returns today's date key string.
  static String todayKey() => dateKey(today());
}
