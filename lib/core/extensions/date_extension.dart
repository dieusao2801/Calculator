import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  /// Định dạng mặc định: "Jun 03, 17:08"
  String formatTime() {
    return DateFormat('MMM dd, HH:mm').format(this);
  }

  /// Định dạng chỉ giờ: "17:08"
  String toHourMinute() {
    return DateFormat('HH:mm').format(this);
  }

  /// Định dạng đầy đủ: "June 03, 2024 - 5:08 PM"
  String toFullDateTime() {
    return DateFormat('MMMM dd, yyyy - h:mm a').format(this);
  }

  /// Kiểm tra xem có phải ngày hôm nay không
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  /// Kiểm tra xem có phải ngày hôm qua không
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day && yesterday.month == month && yesterday.year == year;
  }

  /// Hiển thị thông minh: "Today", "Yesterday" hoặc "Jun 03"
  String toSmartDate() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return DateFormat('MMM dd').format(this);
  }
}
