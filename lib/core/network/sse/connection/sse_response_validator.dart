import 'dart:io';

import '../../../errors/sse_exception.dart';

class SseResponseValidator {
  const SseResponseValidator();

  void validate(HttpClientResponse response) {
    _validateStatusCode(response.statusCode);
    _validateContentType(response);
  }

  void _validateStatusCode(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      throw const SseUnauthorizedException();
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw SseServerException(statusCode);
    }
  }

  void _validateContentType(HttpClientResponse response) {
    final contentType = response.headers.contentType?.mimeType;

    if (contentType == null) {
      return;
    }

    if (contentType != 'text/event-stream') {
      throw SseInvalidContentTypeException(contentType);
    }
  }
}
