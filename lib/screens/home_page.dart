import 'package:flutter/material.dart';
import '../models/calender_day.dart';
import '../services/api_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  late int _month;
  late int _year;
  late Future<CalendarDay> _todayFuture;
  late Future<List<CalendarDay>> _calendarFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _todayFuture = ApiService.fetchToday();
    _calendarFuture = ApiService.fetchCalendar(_month, _year);
  }


  void _changeMonth(int delta) {
    setState(() {
      final date = DateTime(_year, _month + delta);
      _month = date.month;
      _year = date.year;
      _calendarFuture = ApiService.fetchCalendar(_month, _year);
    });
  }


  void _retry() {
    setState(() {
      _todayFuture = ApiService.fetchToday();
      _calendarFuture = ApiService.fetchCalendar(_month, _year);
    });
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Terjadi kesalahan. Periksa koneksi internet.'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _retry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Hijriah')),
      body: Column(
        children: [

          FutureBuilder<CalendarDay>(
            future: _todayFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) return const SizedBox.shrink();
              final t = snapshot.data!;
              return Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const Icon(Icons.today),
                  title: Text(
                    '${t.hijriDay} ${t.hijriMonthEn} ${t.hijriYear} H',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${t.weekdayEn}, ${t.gregorianDate}'),
                ),
              );
            },
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_bulan[_month - 1]} $_year',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          Expanded(
            child: FutureBuilder<List<CalendarDay>>(
              future: _calendarFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _errorView();
                }

                final days = snapshot.data!;
                return ListView.builder(
                  itemCount: days.length,
                  itemBuilder: (context, i) {
                    final d = days[i];
                    final hasHoliday = d.holidays.isNotEmpty;
                    return ListTile(
                      leading: CircleAvatar(child: Text(d.hijriDay)),
                      title: Text('${d.hijriDay} ${d.hijriMonthEn} ${d.hijriYear} H'),
                      subtitle: Text(
                        '${d.weekdayEn}, ${d.gregorianDate}'
                            '${hasHoliday ? '\n${d.holidays.join(', ')}' : ''}',
                      ),
                      isThreeLine: hasHoliday,
                      tileColor: hasHoliday ? Colors.green.shade50 : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}