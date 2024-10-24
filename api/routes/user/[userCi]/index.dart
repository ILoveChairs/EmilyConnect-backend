import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';

import '../../../utils/field_validations.dart';
import '../../../utils/firebase.dart';
import '../../../utils/firestore_names.dart';
import '../../../utils/header_utils.dart';
import '../../../utils/responses.dart';
import '../../../utils/user_seek_and_destroy.dart';

/// # PATH: /user/{ci}
/// 
/// Allowed methods: [OPTIONS, DELETE, PATCH]
/// 
/// Non-specific errors: 405, 406, 415, 401, 403, 400 => {
///  "error": {string},
///  "msg": {string}
/// }
/// 
/// ## => DELETE
/// 
/// On success: 204
/// 
/// On error: 400, 404, 503 => {"error": {string}, "msg": {string}}
/// 
/// ## => PATCH
/// 
/// Required headers: {"Content-Type": "application/json"}
/// 
/// Expected PATCH body: {
///  first_name: {string} (optional),
///  last_name: {string} (optional)
/// }
/// 
/// On success: 200
/// 
/// On error: 400, 404, 503 => {"error": {string}, "msg": {string}}
/// 
/// ---------------------------------------------------------------
/// 
/// Handles update and deletion of singular users.
/// 
Future<Response> onRequest(RequestContext context, String userCi) async {
  // Init logger
  final logger = context.read<RequestLogger>();

  // Rename
  final request = context.request;

  // Check that methods are correct !=(405)
  if (!(
    request.method == HttpMethod.delete ||
    request.method == HttpMethod.patch
  )) {
    return methodNotAllowed();
  }

  // Try to get json and call patch handler !=(400)
  final Map<String, dynamic> json;
  if (request.method == HttpMethod.patch) {
    try {
      json = await request.json() as Map<String, dynamic>;
    } catch (err) {
      return badRequest(msg: 'Json is invalid.');
    }
    return patchRequest(request, userCi, json, logger);
  }

  // Redirect to delete handler
  if (request.method == HttpMethod.delete) {
    return deleteRequest(request, userCi, logger);
  }

  // Should not reach here !=(500)
  logger.error('End of script error');
  return internalServerError(msg: 'Unexpected end of script.');
}


/// DELETE
Future<Response> deleteRequest(
  Request request,
  String userCi,
  RequestLogger logger,
) async {
  // Validate ci !=(400)
  if (
    !isStringFieldValid(userCi)
  ) {
    return badRequest();
  }

  // Calls Firebase Auth to delete user !=(503)
  try {
    // Auth delete
    await auth.deleteUser(userCi);
    // Users collection delete
    await firestore.collection(usersCollection).doc(userCi).delete();
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
  logger.log(Severity.normal, 'user with ci: $userCi deleted');
  return Response(statusCode: 204);
}


/// PATCH
Future<Response> patchRequest(
  Request request,
  String userCi,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
  // Validate fields !=(400)
  final firstName = json['first_name'];
  final lastName = json['last_name'];
  if (
    !isStringFieldValid(userCi) ||
    !isCiValid(userCi)
  ) {
    return badRequest();
  }
  if (
    firstName == null && lastName == null ||
    !customHas(
    json,
    requiredHeaders: [],
    optionalHeaders: ['first_name', 'last_name'],
  )) {
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
    await firestore.collection('users').doc(userCi).update(newRequest);
    await userSeekAndUpdate(userCi, newRequest);
  } catch  (err) {
    if (err is FirebaseFirestoreAdminException) {
      if (err.code == 'NOT_FOUND') {
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
