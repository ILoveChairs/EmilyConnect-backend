import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';

import '../../utils/ci.dart';
import '../../utils/firebase.dart';
import '../../utils/firestore_names.dart';
import '../../utils/responses.dart';
import '../../utils/roles.dart';
import '../../utils/user_seek_and_destroy.dart';

Future<Response> onRequest(RequestContext context) async {
  /// PATH: /user
  /// ALLOWED METHODS: [OPTIONS, POST, DELETE, PATCH]
  /// REQUIRED HEADERS: {'Content-Type': 'application/json'}
  /// NON-SPECIFIC ERRORS: 405, 406, 415, 401, 403, 400 => {
  ///  'error': <string>,
  ///  'msg': <string>
  /// }
  /// 
  /// => POST
  /// EXPECTED POST BODY: {
  ///  ci: <string>,
  ///  first_name: <string>,
  ///  last_name: <string>,
  ///  role: <string> (optional)
  /// }
  /// ON SUCCESS: 201
  /// ON ERROR: 400, 404, 503 => {'error': <string>, 'msg': <string>}
  /// 
  /// => DELETE
  /// EXPECTED DELETE BODY: {
  ///  ci: <string>
  /// }
  /// ON SUCCESS: 204
  /// ON ERROR: 400, 404, 503 => {'error': <string>, 'msg': <string>}
  /// 
  /// => PATCH
  /// EXPECTED PATCH BODY: {
  ///  ci: <string>,
  ///  first_name: <string> (optional),
  ///  last_name: <string> (optional)
  /// }
  /// ON SUCCESS: 200
  /// ON ERROR: 400, 404, 503 => {'error': <string>, 'msg': <string>}
  /// 
  /// Handles creation and deletion of singular users.
  /// Updates are not implemented yet.
  /// Reads will probably not be implemented as it can be
  /// directly done through Firestore.

  // Init logger
  final logger = context.read<RequestLogger>();

  // Rename
  final request = context.request;

  // Check that methods are correct !=(405)
  if (!(
    request.method == HttpMethod.post ||
    request.method == HttpMethod.delete ||
    request.method == HttpMethod.patch
  )) {
    return methodNotAllowed();
  }

  // Check that accept has json !=(406)
  final accept = request.headers['Accept'];
  if (accept != null && !(
     accept.contains('application/json') ||
     accept.contains('application/*') ||
     accept.contains('*/*')
  )) {
    return notAcceptable();
  }

  // Check that content is json via header !=(415)
  if (request.headers['Content-Type'] != 'application/json') {
    return unsopportedMediaType();
  }

  // TODO(ILoveChairs): Authentication check !=(401)

  // TODO(ILoveChairs): Authorization check !=(403)

  // Try to get json !=(400)
  final Map<String, dynamic> json;
  try {
    json = await request.json() as Map<String, dynamic>;
  } catch (err) {
    return badRequest(msg: 'Json is invalid.');
  }

  // Redirect to function depending on method
  if (request.method == HttpMethod.post) {
    return postRequest(request, json, logger);
  } else if (request.method == HttpMethod.delete) {
    return deleteRequest(request, json, logger);
  } else if (request.method == HttpMethod.patch) {
    return patchRequest(request, json, logger);
  }

  // Should not reach here !=(500)
  logger.error('End of script error');
  return internalServerError(msg: 'Unexpected end of script.');
}


Future<Response> postRequest(
  Request request,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
  /// POST

  // Validate fields !=(400)
  final ci = json['ci'];
  final firstName = json['first_name'];
  final lastName = json['last_name'];
  final role = json['role'];
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
  if (role != null && role is! String) {
    return badRequest();
  }
  // I do not trust the &&
  if (role != null && !isRole(role as String)) {
    return badRequest();
  }

  // Creates request to create user
  final createUserRequest = CreateRequest(
    uid: ci,
    email: '$ci@emilydickenson.com',
    password: ci,
    displayName: ci,
  );

  // Calls Firebase Auth and Firestore to create user !=(503)
  try {
    await auth.createUser(createUserRequest);
    await firestore.collection(usersCollection).doc(ci).set(
      role == null ? {
        'first_name': firstName,
        'last_name': lastName,
      } : {
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      },
    );
  } catch (err) {
    if (err is FirebaseAuthAdminException) {
      if (err.errorCode == AuthClientErrorCode.uidAlreadyExists) {
        return conflict(msg: 'User already exists.');
      }
      return serviceUnavailable(msg: err.message);
    } else if (err is FirebaseFirestoreAdminException) {
      // It will try to delete the auth user when firestore save fails
      try {
        await auth.deleteUser(ci);
      } catch (nerr) {
        // Do nothing
      }
      return serviceUnavailable(msg: err.message);
    } else {
      logger.error(err.toString());
      return serviceUnavailable(msg: 'Unexpected error.');
    }
  }

  // Returns appropiate response
  logger.normal('user with ci: $ci created');
  return Response(statusCode: 201);
}


Future<Response> deleteRequest(
  Request request,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
  /// DELETE

  // Validate fields !=(400)
  final ci = json['ci'];
  if (
    ci == null ||
    ci is! String
  ) {
    return badRequest();
  }

  // Calls Firebase Auth to delete user !=(503)
  try {
    // Auth delete
    await auth.deleteUser(ci);
    // Users collection delete
    await firestore.collection(usersCollection).doc(ci).delete();
    // Classes/students delete
    await userSeekAndDestroy(ci);
  } catch (err) {
    if (err is FirebaseAuthAdminException) {
      if (err.errorCode == AuthClientErrorCode.userNotFound) {
        return notFound();
      }
      return serviceUnavailable(msg: err.message);
    } else {
      logger.log(Severity.error, err.toString());
      return serviceUnavailable(msg: 'Unexpected error.');
    }
  }

  // Returns appropiate response
  logger.log(Severity.normal, 'user with ci: $ci deleted');
  return Response(statusCode: 204);
}


Future<Response> patchRequest(
  Request request,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
  /// PATCH

  // Validate fields !=(400)
  final ci = json['ci'];
  final firstName = json['first_name'];
  final lastName = json['last_name'];
  if (
    ci == null ||
    ci is! String ||
    !ciValidate(ci)
  ) {
    return badRequest();
  }
  if (firstName != null && firstName is! String) {
    return badRequest();
  }
  if (lastName != null && lastName is! String) {
    return badRequest();
  }

  // Form request for update
  final newRequest = <String, dynamic>{};
  if (firstName != null) {
    newRequest['first_name'] = firstName;
  }
  if (lastName != null) {
    newRequest['last_name'] = lastName;
  }

  // Firestore call
  try {
    await firestore.collection('users').doc(ci).update(newRequest);
  } catch  (err) {
    if (err is FirebaseFirestoreAdminException) {
      // TODO(ILoveChairs): Search for document not found error code on update
      if (err.code == '') {
        return notFound();
      } else {
        return serviceUnavailable();
      }
    } else {
      return internalServerError();
    }
  }

  // Return appropiate response (200)
  return Response();
}
