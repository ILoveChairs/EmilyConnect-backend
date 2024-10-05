
import 'package:dart_frog/dart_frog.dart';

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
