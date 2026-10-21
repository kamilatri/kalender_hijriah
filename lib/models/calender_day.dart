class CalendarDay {
  final String hijriDay;
  final String hijriMonthEn;
  final String hijriYear;
  final String weekdayEn;
  final String gregorianDate;
  final List<String> holidays;

  CalendarDay({
    required this.hijriDay,
    required this.hijriMonthEn,
    required this.hijriYear,
    required this.weekdayEn,
    required this.gregorianDate,
    required this.holidays,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    final hijri = json['hijri'];
    final greg = json['gregorian'];

    return CalendarDay(
      hijriDay: hijri['day'],
      hijriMonthEn: hijri['month']['en'],
      hijriYear: hijri['year'],
      weekdayEn: greg['weekday']['en'],
      gregorianDate: greg['date'],
      holidays: List<String>.from(hijri['holidays']),
    );
  }
}