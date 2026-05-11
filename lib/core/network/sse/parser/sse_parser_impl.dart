import 'package:sarmayex/core/network/sse/sse_event.dart';

import 'sse_parser.dart';

class SseParserImpl implements SseParser {
  String? _id;
  String? _event;
  Duration? _retry;
  final StringBuffer _dataBuffer = StringBuffer();

  @override
  SseEvent? parseLine(String line) {
    final normalizedLine = _normalizeLine(line);

    if (normalizedLine.isEmpty) {
      return _buildEventAndReset();
    }

    if (normalizedLine.startsWith(':')) {
      return null;
    }

    final field = _parseField(normalizedLine);
    _applyField(field);

    return null;
  }

  @override
  SseEvent? close() {
    return _buildEventAndReset();
  }

  String _normalizeLine(String line) {
    return line.endsWith('\r') ? line.substring(0, line.length - 1) : line;
  }

  _SseField _parseField(String line) {
    final separatorIndex = line.indexOf(':');

    if (separatorIndex == -1) {
      return _SseField(name: line, value: '');
    }

    final name = line.substring(0, separatorIndex);
    final rawValue = line.substring(separatorIndex + 1);
    final value = rawValue.startsWith(' ') ? rawValue.substring(1) : rawValue;

    return _SseField(name: name, value: value);
  }

  void _applyField(_SseField field) {
    switch (field.name) {
      case 'id':
        _id = field.value;
        break;

      case 'event':
        _event = field.value;
        break;
      case 'data':
        if (_dataBuffer.isNotEmpty) {
          _dataBuffer.write('\n');
        }
        _dataBuffer.write(field.value);
        break;

      case 'retry':
        final retryMs = int.tryParse(field.value);
        if (retryMs != null && retryMs >= 0) {
          _retry = Duration(milliseconds: retryMs);
        }
        break;
    }
  }

  SseEvent? _buildEventAndReset() {
    if (_id == null &&
        _event == null &&
        _retry == null &&
        _dataBuffer.isEmpty) {
      return null;
    }

    final event = SseEvent(
      id: _id,
      event: _event,
      data: _dataBuffer.toString(),
      retry: _retry,
    );

    _reset();

    return event;
  }

  void _reset() {
    _id = null;
    _event = null;
    _retry = null;
    _dataBuffer.clear();
  }
}

class _SseField {
  final String name;
  final String value;

  const _SseField({
    required this.name,
    required this.value,
  });
}
