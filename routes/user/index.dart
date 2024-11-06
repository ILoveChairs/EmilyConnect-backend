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

/// # PATH: /user
/// 
/// Allowed methods: [OPTIONS, POST, DELETE]
/// 
/// Non-specific errors: 405, 406, 415, 401, 403, 400 => {
///  "error": {string},
///  "msg": {string}
/// }
/// 
/// ## => POST
/// 
/// Required headers: {"Content-Type": "application/json"}
/// 
/// Expected POST body for singular users: {
///  "ci": {string},
///  "first_name": {string},
///  "last_name": {string},
///  "role": {string} (optional)
/// }
/// 
/// On Success: 201
/// 
/// On Error: 400, 404, 503 => {"error": {string}, "msg": {string}}
/// 
/// Expected POST body for multiple users: {
///  "users": [
///   ...
///   {
///   "ci": {string},
///   "first_name": {string},
///   "last_name": {string},
///   "role": {string} (optional)
///   }
/// ]}
/// 
/// On Success: 200 => {"results": {..."ci": {string}}}
/// 
/// On Error: 400 => {"error": {string}, "msg": {string}}
/// 
/// ## => DELETE
/// 
/// Required headers: {"Content-Type": "application/json"}
/// 
/// Expected DELETE body for multiple users: {
///  "users": [
///   ...
///   {string}
/// ]}
/// 
/// On success: 204
/// 
/// On error: 400 => {"error": {string}, "msg": {string}}
/// 
/// ---------------------------------------------------------------
/// 
/// Handles creation of singular users, and creation and deletion of
/// multiple users by passing in a list.
/// Singular user update and Delete are delegated to user/{ci}
/// 
/// Multiple user creation returns a list with all the CIs and if they were
/// successfully created. If no error was encountered the value will be
/// "User created", else the error.
/// 
Future<Response> onRequest(RequestContext context) async {
  // Init logger
  final logger = context.read<RequestLogger>();

  // Rename
  final request = context.request;

  // Check that methods are correct !=(405)
  if (!(
    request.method == HttpMethod.post ||
    request.method == HttpMethod.delete
  )) {
    return methodNotAllowed();
  }

  // Try to get json !=(400)
  final Map<String, dynamic> json;
  try {
    json = await request.json() as Map<String, dynamic>;
  } catch (err) {
    return badRequest(msg: 'Json is invalid.');
  }

  // If users exist redirect to multiple checks
  final users = json['users'];
  if (users != null) {
    // Redirect to multiple post/delete handler
    if (request.method == HttpMethod.post) {
      return multiplePostRequest(request, json, logger);
    } else if (request.method == HttpMethod.delete) {
      return multipleDeleteRequest(request, json, logger);
    }

    // Should not reach here !=(500)
    logger.error('End of script error');
    return internalServerError(msg: 'Unexpected end of script.');
  }

  // Redirect to singular user post
  if (request.method == HttpMethod.post) {
    return postRequest(request, json, logger);
  }

  // Should not reach here !=(500)
  logger.error('End of script error');
  return internalServerError(msg: 'Unexpected end of script.');
}


/// Singular user POST
Future<Response> postRequest(
  Request request,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
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
    'role': role,
  };

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


/// Multiple user POST
Future<Response> multiplePostRequest(
  Request request,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
  // Validate fields !=(400)
  final userList = json['users'];
  if (
    userList == null || userList is! List ||
    userList.isEmpty || userList.length > 100
  ) {
    return badRequest();
  }
  for (final user in userList) {
    if (user is! Map) {
      return badRequest();
    }
    final ci = user['ci'];
    final firstName = user['first_name'];
    final lastName = user['last_name'];
    final role = user['role'];
    if (
      ci == null || ci is! String ||
      !isStringFieldValid(ci) ||
      firstName == null || firstName is! String ||
      !isStringFieldValid(firstName) ||
      lastName == null || lastName is! String ||
      !isStringFieldValid(lastName)
    ) {
      return badRequest();
    }
    if (!isCiValid(ci)) {
      return badRequest();
    }
    if (role != null && role is! String) {
      return badRequest();
    }
    // I do not trust the &&
    if (role != null && !isRole(role as String)) {
      return badRequest();
    }
  }
  final checkedUserList = userList.cast<Map<String, dynamic>>();

  // Creates request to create user
  final userRequestList = <CreateRequest>[];
  for (final user in checkedUserList) {
    final ci = user['ci']! as String;
    userRequestList.add(
      CreateRequest(
        uid: ci,
        email: '$ci@emilydickenson.com',
        password: ci,
        displayName: ci,
      ),
    );
  }

  // Creates list to store results of user creations
  final results = <String, String>{};

  // Calls Firebase Auth to create user !=(503)
  for (var i = 0; i < checkedUserList.length; i++) {
    final user = checkedUserList[i];
    final ci = user['ci']! as String;
    final firstName = user['first_name']! as String;
    final lastName = user['last_name']! as String;
    final role = user['role'] as String?;
    try {
      await auth.createUser(userRequestList[i]);
      await firestore.collection(usersCollection).doc(ci).set({
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
        },
      );
      results[ci] = 'User created';
    } catch (err) {
      // Errors will be added to results
      if (err is FirebaseAuthAdminException) {
        results[ci] = err.message;
      } else if (err is FirebaseFirestoreAdminException) {
        // It will try to delete the auth user when firestore save fails
        try {
          await auth.deleteUser(ci);
        } catch (nerr) {
          // Do nothing
        }
        results[ci] = err.message;
      } else {
        logger.error(err.toString());
        results[ci] = 'Unexpected error';
      }
    }
  }

  // Returns appropiate response
  logger.normal('list of users created: $results');
  return Response.json(
    headers: {'Content-Type': 'application/json'},
    body: {'results': results},
  );
}


/// Multiple user DELETE
Future<Response> multipleDeleteRequest(
  Request request,
  Map<String, dynamic> json,
  RequestLogger logger,
) async {
  // Validate fields !=(400)
  final userList = json['users'];
  if (userList == null || userList is! List || userList.isEmpty) {
    return badRequest();
  }
  for (final ci in userList) {
    if (
      ci == null ||
      ci is! String
    ) {
      return badRequest();
    }
  }

  for (var i = 0; i < userList.length; i++) {
    final ci = userList[i] as String;
    // Auth delete
    await auth.deleteUser(ci);
    // Users collection delete
    await firestore.collection(usersCollection).doc(ci).delete();
  }

  // Returns appropiate response
  logger.normal('users deleted: $userList');
  return Response(statusCode: 204);
}
