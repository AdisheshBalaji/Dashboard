import 'package:dashbaord/constants/enums/schedule_color_palette.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/widgets/timetable/scroll_to_today_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

class MonthViewScreen extends StatefulWidget {
  final BuildContext context;
  final Timetable? timetable;
  final Function(DateTime) onDayPressed;

  const MonthViewScreen({
    super.key,
    required this.context,
    required this.timetable,
    required this.onDayPressed,
  });

  @override
  State<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> events;

  @override
  void initState() {
    super.initState();
    events = convertTimetableToEvents(widget.timetable?.slots ?? []);
  }

  List<Map<String, dynamic>> convertTimetableToEvents(List<Lecture> lectures) {
    final now = DateTime.now();
    int month;

    if (now.month >= 1 && now.month <= 4) {
      month = 5;
    } else if (now.month >= 8 && now.month <= 11) {
      month = 12;
    } else {
      month = now.month;
    }

    DateTime endDate = DateTime(now.year, month, 5);
    final events = <Map<String, dynamic>>[];

    final Map<String, int> dayToWeekday = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    for (var lecture in lectures) {
      int? targetWeekday = dayToWeekday[lecture.day];

      if (targetWeekday == null) continue;

      int daysToAdd = (targetWeekday - now.weekday) % 7;
      if (daysToAdd < 0) daysToAdd += 7;

      DateTime nextOccurrence = now.add(Duration(days: daysToAdd));

      while (nextOccurrence.isBefore(endDate) ||
          nextOccurrence.isAtSameMomentAs(endDate)) {
        events.add({
          "title": lecture.courseCode,
          "date": nextOccurrence,
          "time": "${lecture.startTime} - ${lecture.endTime}",
          "classroom": lecture.classRoom,
          "type": "class",
        });

        nextOccurrence = nextOccurrence.add(const Duration(days: 7));
      }
    }

    return events;
  }

  void _scrollToToday() {
    DateTime today = DateTime.now();
    double offset = today.day * 1;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PagedVerticalCalendar(
            minDate: DateTime.now().subtract(const Duration(days: 30)),
            scrollController: _scrollController,
            addAutomaticKeepAlives: true,
            startWeekWithSunday: true,
            monthBuilder: (context, month, year) {
              final formattedMonth =
                  DateFormat('MMMM yyyy').format(DateTime(year, month));
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              );
            },
            dayBuilder: (context, date) {
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final dayEvents = events
                  .where((e) =>
                      DateFormat('yyyy-MM-dd').format(e['date']) == dateStr)
                  .toList();

              bool isToday = DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year;

              return GestureDetector(
                onTap: () => widget.onDayPressed(date),
                child: SizedBox(
                  height: 60, // fixed height to avoid overflow
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        alignment: WrapAlignment.center,
                        children: dayEvents.take(5).map((lecture) {
                          return Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: getColorForTitle(lecture["title"]),
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          TodayButton(onPressed: _scrollToToday),
        ],
      ),
    );
  }
}
