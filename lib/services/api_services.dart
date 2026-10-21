import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calender_day.dart';

class ApiService {
  static const String _base = 'https://api.aladhan.com/v1';


  static Future<CalendarDay> fetchToday() async {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');

    final response =
    await http.get(Uri.parse('$_base/gToH/$d-$m-${now.year}'));

    if (response.statusCode == 200) {
      return CalendarDay.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal memuat tanggal hari ini (${response.statusCode})');
    }
  }


  static Future<List<CalendarDay>> fetchCalendar(int month, int year) async {
    final response =
    await http.get(Uri.parse('$_base/gToHCalendar/$month/$year'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => CalendarDay.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kalender (${response.statusCode})');
    }
  }
}