import 'package:uuid/uuid.dart';
import '../models/deadline.dart';

class DeadlineExtractor {
  static final _uuid = const Uuid();

  static final List<RegExp> _datePatterns = [
    RegExp(r'(?:scade|entro)\s+il\s+(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})',
        caseSensitive: false),
    RegExp(r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})',
        caseSensitive: false),
  ];

  static final List<RegExp> _amountPatterns = [
    RegExp(r'(?:importo|totale|somma)\D+(\d+[\,\.]\d{1,2})',
        caseSensitive: false),
    RegExp(r'(\d+[\,\.]\d{1,2})\s*(?:€|eur|euro)',
        caseSensitive: false),
  ];

  List<Deadline> extract(String text, {String defaultTitle = 'Scadenza'}) {
    final List<DateTime> dates = [];

    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(text)) {
        try {
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          var year = int.parse(match.group(3)!);
          if (year < 100) year += 2000;
          dates.add(DateTime(year, month, day, 9, 0));
        } catch (_) {
          continue;
        }
      }
    }

    if (dates.isEmpty) return [];

    double? amount;
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '.');
        final parsed = double.tryParse(raw);
        if (parsed != null) {
          amount = parsed;
          break;
        }
      }
    }

    return dates
        .map(
          (dt) => Deadline(
            id: _uuid.v4(),
            title: defaultTitle,
            dueDate: dt,
            amount: amount,
            source: 'text',
          ),
        )
        .toList();
  }
}
