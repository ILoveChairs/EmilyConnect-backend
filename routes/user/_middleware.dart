
import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

import '../../utils/field_validations.dart';
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

    // TODO(ILoveChairs): Auth

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
        int.parse(contentSize) > maxIndexContentSize
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
