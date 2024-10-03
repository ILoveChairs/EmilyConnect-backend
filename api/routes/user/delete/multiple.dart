import 'package:dart_frog/dart_frog.dart';

import '../../../utils/firebase.dart';

Future<Response> onRequest(RequestContext context) async {
  /**
   * 
   */

  // Rename
  final request = context.request;

  // Check that method is DELETE !=(405)
  if (request.method != HttpMethod.delete) {
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
  final userList = json['users'];
  if (userList == null || userList is! List || userList.isEmpty) {
    return badRequest();
  }
  for (final user in userList) {
    final ci = user['ci'];
    if (
      ci == null ||
      ci is! String
    ) {
      return badRequest();
    }
  }


  // Calls Firebase Auth to create user !=(503)
  for (var i = 0; i < userList.length; i++) {
    try {
      await auth.deleteUsers(userList as List<String>);
    } catch (err) {
      return serviceUnavailable();
    }
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
