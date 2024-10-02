import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('Errors', () {
    test('Invalid GET method', () async {
      final context = _MockRequestContext();
      final response = await route.onRequest(context);
      when(() => context.read<Map<String, dynamic>>()).thenReturn(
        {'ci': '54910817', 'password': 'Holamundo'},
      );
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
      expect(
        response.json(),
        completion(equals({'error': 'Method Not Allowed'})),
      );
    });
  });
}
