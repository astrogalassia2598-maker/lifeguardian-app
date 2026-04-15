class Deadline {
  final String id;
  final String title;
  final DateTime dueDate;
  final double? amount;
  final String source;

  Deadline({
    required this.id,
    required this.title,
    required this.dueDate,
    this.amount,
    required this.source,
  });
}
