import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';

import '../../utils/field_validations.dart';
import '../../utils/firebase.dart';
import '../../utils/firestore_names.dart';
import '../../utils/header_utils.dart';
import '../../utils/responses.dart';
import '../../utils/roles.dart';

Future<Response> onRequest(RequestContext context) async {
  /// PATH: /user
  /// ALLOWED METHODS: [OPTIONS, POST]
  /// NON-SPECIFIC ERRORS: 405, 406, 415, 401, 403, 400 => {
  ///  'error': <string>,
  ///  'msg': <string>
  /// }
  /// 
  /// => POST
  /// REQUIRED HEADERS: {'Content-Type': 'application/json'}
  /// EXPECTED POST BODY: {
  ///  ci: <string>,
  ///  first_name: <string>,
  ///  last_name: <string>,
  ///  role: <string> (optional)
  /// }
  /// ON SUCCESS: 201
  /// ON ERROR: 400, 404, 503 => {'error': <string>, 'msg': <string>}
  /// 
  /// Handles creation of singular users.
  /// Update and Delete are delegated to user/[ci]
  /// 

  // Init logger
  final logger = context.read<RequestLogger>();

  // Rename
  final request = context.request;

  // Check that methods are correct !=(405)
  if (request.method != HttpMethod.post) {
    return methodNotAllowed();
  }

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

  // Log post string
  logger.info('post');

  // Validate fields !=(400)
  final ci = json['ci'];
  final firstName = json['first_name'];
  final lastName = json['last_name'];
  final role = json['role'];
  if (!customHas(
    json,
    requiredHeaders: ['ci', 'first_name', 'last_name'],
    optionalHeaders: ['role'],
  )) {
    return badRequest();
  }
  if (!isCiValid(ci as String)) {
    return badRequest();
  }
  if (role != null && !(role is String && isRole(role))) {
    return badRequest();
  }

  // Defines request to create user in Firebase Authentication
  final createUserRequest = CreateRequest(
    uid: ci,
    email: '$ci@emilydickenson.com',
    password: ci,
    displayName: ci,
  );

  // Defines document data to create user in Firestore
  final userDoc = {
      'first_name': firstName,
      'last_name': lastName,
  };
  if (role != null) {
    userDoc['role'] = role as String;
  }

  // Calls Firebase Auth and Firestore to create user !=(503)
  try {
    await auth.createUser(createUserRequest);
    await firestore.collection(usersCollection).doc(ci).set(userDoc);
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
      } catch (err2) {
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
