
import 'package:dart_frog/dart_frog.dart';

/// 
/// ERROR RESPONSES
/// 


// Allow string used for 'Allow' headers
const allows = 'OPTIONS, POST, DELETE';


// 405
Response methodNotAllowed({String? err, String? allowed, String? msg}) {
  return Response.json(
    statusCode: 405,
    headers: {
      'Content-Type': 'application/json',
      'Allow': allowed ?? allows,
    },
    body: msg == null ? 
    {'error': err ?? 'Method Not Allowed'} :
    {'error': err ?? 'Method Not Allowed', 'msg': msg},
  );
}


// 406
Response notAcceptable({String? err, String? msg}) {
  return Response.json(
    statusCode: 406,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Not Acceptable'} :
    {'error': err ?? 'Not Acceptable', 'msg': msg},
  );
}


// 400
Response badRequest({String? err, String? msg}) {
  return Response.json( 
    statusCode: 400,
    headers: {
      'Content-Type': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Bad Request'} :
    {'error': err ?? 'Bad Request', 'msg': msg},
  );
}


// 401
Response unauthorized({String? err, String? msg}) {
  return Response.json(
    statusCode: 401,
    headers: {
      'Content-Type': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Unauthorized'} :
    {'error': err ?? 'Unauthorized', 'msg': msg},
  );
}


// 403
Response forbidden({String? err, String? msg}) {
  return Response.json(
    statusCode: 403,
    headers: {
      'Content-Type': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Forbidden'} :
    {'error': err ?? 'Forbidden', 'msg': msg},
  );
}


// 404
Response notFound({String? err, String? msg}) {
  return Response.json(
    statusCode: 404,
    headers: {
      'Content-Type': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Not Found'} :
    {'error': err ?? 'Not Found', 'msg': msg},
  );
}


// 409
Response conflict({String? err, String? msg}) {
  return Response.json(
    statusCode: 409,
    headers: {
      'Content-Type': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Conflict'} :
    {'error': err ?? 'Conflict', 'msg': msg},
  );
}


// 500
Response internalServerError({String? err, String? msg}) {
  return Response.json(
    statusCode: 500,
    headers: {
      'Content-Type': 'application/json',
    },
    body: msg == null ? 
    {'error': err ?? 'Internal Server Error'} :
    {'error': err ?? 'Internal Server Error', 'msg': msg},
  );
}


// 503
Response serviceUnavailable({String? err, String? msg}) {
  return Response.json(
    statusCode: 503,
    headers: {'Content-Type': 'application/json'},
    body: msg == null ? 
    {'error': err ?? 'Service Unavailable'} :
    {'error': err ?? 'Service Unavailable', 'msg': msg},
  );
}
