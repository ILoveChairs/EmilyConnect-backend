
import 'field_validations.dart';

bool customHas(Map<String, Object?> headers, {
  required List<String> requiredHeaders,
  List<String>? optionalHeaders,
}) {
  final requiredMap = <String, bool>{};
  final hasOptionals = optionalHeaders != null && optionalHeaders.isNotEmpty;

  for (final header in requiredHeaders) {
    requiredMap[header] = false;
  }

  for (final header in headers.keys) {
    if (requiredHeaders.contains(header)) {
      final headerValue = headers[header];
      if (!(headerValue is String || headerValue is List)) {
        return false;
      }
      if (headerValue is String && !isStringFieldValid(headerValue)) {
        return false;
      } else if (headerValue is List && header == 'users') {
        return false;
      }
      requiredMap[header] = true;
    } else if (!(hasOptionals && optionalHeaders.contains(header))) {
      return false;
    }
  }

  if (requiredMap.containsValue(false)) {
    return false;
  }

  return true;
}
