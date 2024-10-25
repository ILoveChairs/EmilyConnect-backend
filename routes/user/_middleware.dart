
import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

import '../../utils/caches.dart';
import '../../utils/field_validations.dart';
import '../../utils/firebase.dart';
import '../../utils/responses.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(
        fromShelfMiddleware(
          shelf.corsHeaders(
            headers: {
              shelf.ACCESS_CONTROL_ALLOW_METHODS: allows,
              shelf.ACCESS_CONTROL_ALLOW_ORIGIN: 'http://localhost',
            },
          ),
        ),
      )
      .use(httpRestrictions);
}


/// Checks that requests are compliant
Handler httpRestrictions(Handler handler) {
  return (context) async {
    // Rename
    final request = context.request;

    // Check that uri is not too long !=(414)
    if (request.uri.toString().length > 256) {
      return uriTooLong();
    }

    // Check that accept has json !=(406)
    final accept = request.headers['Accept'];
    if (accept == null || !(
      accept.contains('application/json') ||
      accept.contains('application/*') ||
      accept.contains('*/*')
    )) {
      return notAcceptable();
    }

    /*
     ! Framework does not allow auth
    // Check that is authenticated !=(401)
    final authHeader = request.headers['Authorization'];
    if (
      authHeader == null ||
      !authHeader.startsWith('Bearer ') ||
      authHeader == 'Bearer '
    ) {
      return unauthorized();
    }
    final idToken = authHeader.split('Bearer ')[1];
    final tokenPayload = await getTokenPayload(idToken);
    if (tokenPayload == null) {
      return unauthorized(msg: 'Invalid credentials.');
    }

    // Check that is admin !=(403)
    final requesterCi = tokenPayload.uid;
    if (!(await isPermitted(requesterCi))) {
      return forbidden();
    }
    */

    // POST and PATCH specific
    if (
      request.method == HttpMethod.post ||
      request.method ==  HttpMethod.patch
    ) {
      final contentType = request.headers['Content-Type'];
      final contentSize = request.headers['Content-Length'];

      // Check that required headers exist !=(400)
      if (contentType == null) {
        return badRequest(msg: 'Headers are missing.');
      }

      // Check that content length exist !=(411)
      if (contentSize == null) {
        return lengthRequired();
      }

      // Check that content is valid !=(400)
      if (
        int.tryParse(contentSize) == null ||
        int.parse(contentSize) == 0
      ) {
        return badRequest(msg: 'No content sent.');
      }

      // Check that content size is below limit !=(413)
      if (
        int.tryParse(contentSize) == null ||
        int.parse(contentSize) > maxContentSize
      ) {
        return contentTooLarge();
      }

      // Check that content is json via header !=(415)
      if (!contentType.contains('application/json') ) {
        return unsopportedMediaType();
      }
    }

    // Let it transfer to route
    final response = await handler(context);
    return response;
  };
}


/// Checks if the requester is logged in
Future<DecodedIdToken?> getTokenPayload(String idToken) async {
  try {
    return await auth.verifyIdToken(idToken, checkRevoked: true);
  // ignore: avoid_catching_errors
  } catch (err) {
    return null;
  }
}


/// Checks if has permissions to access API endpoints
Future<bool> isPermitted(String requesterCi) async {
  final cachedUser = await cachedUsers.get(requesterCi);
  if (!cachedUser.exists) {
    return false;
  }
  final role = cachedUser.userData!.role;
  if (role != 'Admin') {
    return false;
  }
  return true;
}
