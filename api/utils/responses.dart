
import 'package:dart_frog/dart_frog.dart';

/// 
/// ERROR RESPONSES
/// 


// Allow string used for 'Allow' headers
const allows = 'OPTIONS, POST, DELETE';


// 405
Response methodNotAllowed({
  String msg = 'Only [$allows] methods are allowed.',
}) {
  return Response.json(
    statusCode: 405,
    headers: {
      'Content-Type': 'application/json',
      'Allow': allows,
    },
    body: {'error': 'Method Not Allowed', 'msg': msg},
  );
}


// 406
Response notAcceptable({
  String msg = 'Response can only be application/json.',
}) {
  return Response.json(
    statusCode: 406,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'application/json',
    },
    body: {'error': 'Not Acceptable', 'msg': msg},
  );
}


// 415
Response unsopportedMediaType({
  String msg = 'Request must be application/json.',
}) {
  return Response.json(
    statusCode: 415,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'application/json',
    },
    body: {'error': 'Unsupported Media Type', 'msg': msg},
  );
}


// 400
Response badRequest({
  String msg = 'Fields are invalid.',
}) {
  return Response.json( 
    statusCode: 400,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Bad Request', 'msg': msg},
  );
}


// 401
Response unauthorized({
  String msg = 'Must provide bearer credentials.',
}) {
  return Response.json(
    statusCode: 401,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Unauthorized', 'msg': msg},
  );
}


// 403
Response forbidden({
  String msg = 'Insufficent piviledges.',
}) {
  return Response.json(
    statusCode: 403,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Forbidden', 'msg': msg},
  );
}


// 404
Response notFound({
  String msg = 'User not found.',
}) {
  return Response.json(
    statusCode: 404,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Not Found', 'msg': msg},
  );
}


// 409
Response conflict({
  String msg = 'User conflict.',
}) {
  return Response.json(
    statusCode: 409,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Conflict', 'msg': msg},
  );
}


// 500
Response internalServerError({
  String msg = 'Unknown',
}) {
  return Response.json(
    statusCode: 500,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Internal Server Error', 'msg': msg},
  );
}


// 503
Response serviceUnavailable({
  String msg = 'Database connection might be disabled.',
}) {
  return Response.json(
    statusCode: 503,
    headers: {'Content-Type': 'application/json'},
    body: {'error': 'Service Unavailable', 'msg': msg},
  );
}
