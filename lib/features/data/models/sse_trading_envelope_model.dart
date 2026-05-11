final class SseTradingEnvelopeModel {
  final String event;
  final Map<String, dynamic> data;

  const SseTradingEnvelopeModel({
    required this.event,
    required this.data,
  });

  factory SseTradingEnvelopeModel.fromJson(Map<String, dynamic> json) {
    final rawEvent = json['event'];
    final rawData = json['data'];

    if (rawEvent == null || rawEvent.toString().isEmpty) {
      throw FormatException('Missing SSE payload event: $json');
    }

    if (rawData is! Map<String, dynamic>) {
      throw FormatException('Invalid SSE payload data: $json');
    }

    return SseTradingEnvelopeModel(
      event: rawEvent.toString(),
      data: rawData,
    );
  }
}
