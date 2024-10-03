import 'package:dart_frog/dart_frog.dart';

import '../utils/ci.dart';
import '../utils/firebase.dart';

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
   * Validates CI/password credentials, reading the stored password in
   * users_private_info/<ci>, and if both password hashes coincide
   * sends a JWT that can be used with Firebase Authentication.
   * 
   * JWTs are used in client's sdk with signInWithCustomToken().
   * 
   * CIs are validated. They must exist to not get a 400 error.
   * 
   * Error responses defined at end of file.
   */

  // Rename
  final request = context.request;

  // Check that method is POST !=(405)
  if (request.method != HttpMethod.post) {
    return methodNotAllowed();
  }

  // Check that body is json with header !=(406)
  if (request.headers['Content-Type'] != 'application/json') {
    return notAcceptable();
  }

  // Try to get json !=(400)
  final Map<String, dynamic> json;
  try {
    json = await request.json() as Map<String, dynamic>;
  } catch (err) {
    return badRequest();
  }

  // Validate fields !=(400)
  final ci = json['ci'];
  final password = json['password'];
  if (
    ci == null ||
    ci is! String ||
    password == null ||
    password is! String ||
    !ciValidate(ci)
  ) {
    return badRequest();
  }

  // TODO(ILoveChairs): do auth

  // Generate token
  final token = await auth.createCustomToken(ci);

  // Return token (200)
  return Response.json(
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'token': token},
  );
}


/// 
/// ERROR RESPONSES
/// 


Response methodNotAllowed() {
  return Response.json(
    statusCode: 405,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'POST',
    },
    body: {'error': 'Method Not Allowed'},
  );
}


Response notAcceptable() {
  return Response.json(
    statusCode: 406,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'application/json',
    },
    body: {'error': 'Not Acceptable'},
  );
}


Response badRequest() {
  return Response.json( 
    statusCode: 400,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Bad Request'},
  );
}


Response unauthorized() {
  return Response.json(
    statusCode: 401,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Unauthorized'},
  );
}
