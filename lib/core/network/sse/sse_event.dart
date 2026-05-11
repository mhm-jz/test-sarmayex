class SseEvent {
  final String? id;
  final String? event;
  final String data;
  final Duration? retry;

  const SseEvent({
    this.id,
    this.event,
    required this.data,
    this.retry,
  });

  bool get hasData => data.trim().isNotEmpty;
}
