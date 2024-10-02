import 'package:dart_frog/dart_frog.dart';

import '../utils/ci.dart';

Future<Response> onRequest(RequestContext context) async {
  /**
   * PATH: /
   * ALLOWED METHODS: [POST]
   * REQUIRED HEADERS {'Content-Type': 'application/json'}
   * POST BODY {ci: <string>, password: <string>}
   * 
   * On error 405, 406, 400, 401 => {'error': <string>}
   * On success 200 => {'token': <string>}
   * 
   * Validates credentials based on CI and sends a request for a token
   * to Firebase Authentication. Returns the token if successful.
   * 
   * CIs are validated. They must exist to not get a 400 error.
   * 
   */

  // Rename
  final request = context.request;

  // Check that method is POST (405)
  if (request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      headers: {
        'Content-Type': 'application/json',
        'Allow': 'POST',
      },
      body: {'error': 'Method Not Allowed'},
    );
  }

  // Check that body is json with header (406)
  if (request.headers['Content-Type'] != 'application/json') {
    return Response.json(
      statusCode: 406,
      headers: {
        'Content-Type': 'application/json',
        'Allow': 'application/json',
      },
      body: {'error': 'Not Acceptable'},
    );
  }

  // Try to get json (400)
  final Map<String, dynamic> json;
  try {
    json = await request.json() as Map<String, dynamic>;
  } catch (err) {
    return Response.json( 
      statusCode: 400,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {'error': 'Bad Request'},
    );
  }

  // Validate fields (400)
  if (
    json['ci'] == null ||
    json['ci'] is! String ||
    json['password'] == null ||
    json['password'] is! String ||
    !ciValidate(json['ci'] as String)
  ) {
    return Response.json(
      statusCode: 400,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {'error': 'Bad Request'},
    );
  }

  // Call Firestore for user ci password if exists
  // todo: implement firestore call

  // Call Firebase Authentication API
  // todo: Implement firebase call
  /*
  const call = false;
  if (call) {
    return Response.json(
      statusCode: 401,
      headers: {
        'Content-Type': 'application/json',
      },
      body: {'error': 'Unauthorized'},
    );
  }
  */
  const token = 'abcdef0123456789';

  // Return token
  return Response.json(
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'token': token},
  );
}
