import 'package:intl/intl.dart';

final fullDateFormat = DateFormat.yMMMMd();
final compactDateFormat = DateFormat.yMMMd();
final timeFormat = DateFormat.Hm();
final monthLabelFormat = DateFormat.MMM();

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
