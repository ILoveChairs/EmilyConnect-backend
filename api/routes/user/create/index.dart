import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../utils/ci.dart';
import '../../../utils/firebase.dart';

Future<Response> onRequest(RequestContext context) async {
  /**
   * 
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
  final firstName = json['first_name'];
  final lastName = json['last_name'];
  if (
    ci == null ||
    ci is! String ||
    firstName == null ||
    firstName is! String ||
    lastName == null ||
    lastName is! String ||
    !ciValidate(ci)
  ) {
    return badRequest();
  }

  // Creates request to create user
  final createUserRequest = CreateRequest(
    uid: ci,
    email: '$ci@emilydickenson.com',
    password: ci,
    displayName: ci,
  );

  // Calls Firebase Auth to create user !=(503)
  try {
    await auth.createUser(createUserRequest);
    await firestore.collection('User').doc(ci).set({
      'first_name': firstName,
      'last_name': lastName,
    });
  } catch (err) {
    return serviceUnavailable();
  }

  // Returns appropiate response
  return Response(statusCode: 201);
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


Response serviceUnavailable() {
  return Response.json(
    statusCode: 503,
    headers: {'Content-Type': 'application/json'},
    body: {'error': 'Service Unavailable'},
  );
}
