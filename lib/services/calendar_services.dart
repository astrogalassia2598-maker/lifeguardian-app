import 'package:device_calendar/device_calendar.dart';
import '../models/deadline.dart';

class CalendarService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  String? _calendarId;

  Future<bool> init() async {
    final permissionsResult = await _plugin.requestPermissions();
    if (!(permissionsResult.isSuccess && permissionsResult.data == true)) {
      return false;
    }

    final calendarsResult = await _plugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return false;
    }

    final defaultCalendar =
        calendarsResult.data!.firstWhere((c) => c.isDefault ?? false,
            orElse: () => calendarsResult.data!.first);

    _calendarId = defaultCalendar.id;
    return true;
  }

  Future<void> addDeadline(Deadline d) async {
    if (_calendarId == null) return;

    final event = Event(
      _calendarId!,
      title: d.title,
      start: d.dueDate,
      end: d.dueDate.add(const Duration(hours: 1)),
      description:
          d.amount != null ? 'Importo: ${d.amount!.toStringAsFixed(2)} €' : '',
    );

    await _plugin.createOrUpdateEvent(event);
  }
}
