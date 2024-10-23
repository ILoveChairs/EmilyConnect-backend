import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';

import '../../utils/field_validations.dart';
import '../../utils/firebase.dart';
import '../../utils/firestore_names.dart';
import '../../utils/responses.dart';
import '../../utils/roles.dart';
import '../../utils/user_seek_and_destroy.dart';

Future<Response> onRequest(RequestContext context) async {
  /// PATH: /user/multiple
  /// ALLOWED METHODS: [POST, DELETE]
  /// REQUIRED HEADERS: {'Content-Type': 'application/json'}
  /// NON-SPECIFIC ERRORS: 405, 406, 415, 401, 403, 400 => {
  ///  'error': <string>,
  ///  'msg': <string>
  /// }
  /// 
  /// => POST
  /// EXPECTED POST BODY: {
  ///  users: [
  ///    ...
  ///    {
  ///      ci: <string>,
  ///      first_name: <string>,
  ///      last_name: <string>,
  ///      role: <string> (optional)
  ///    }
  ///  ]
  /// }
  /// ON SUCCESS: 200 => {'results': {...<ci>: <string>}}
  /// ON ERROR: 400 => {'error': <string>, 'msg': <string>}
  /// 
  /// => DELETE
  /// EXPECTED DELETE BODY: {
  ///  users: [
  ///    ...
  ///    ci: <string>
  ///  ]
  /// }
  /// ON SUCCESS: 200 => {'results': {...<ci>: <string>}}
  /// ON ERROR: 400 => {'error': <string>, 'msg': <string>}
  /// 
  /// Handles creation and deletion of multiple users.
  /// However, if there is an error with any Firebase operation
  /// it will be ignored. However it will be stored in a results
  /// map that is passed as a response.
  /// 
  /// CI is checked to be a valid uruguayan document. Will probably be changed
  /// in the future to not be checked.
  /// 
  /// If the user is created it will appear like this:
  /// {'results': {...<ci>: 'User created'}}
  /// 
  /// If the user is deleted it will appear like this:
  /// {'results': {...<ci>: 'User deleted'}}

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
  final Map<String, Object> json;
  try {
    json = await request.json() as Map<String, Object>;
  } catch (err) {
    return badRequest(msg: 'Json is invalid.');
  }

  // Redirect to function depending on method
  if (request.method == HttpMethod.post) {
    return postRequest(request, json, logger);
  } else if (request.method == HttpMethod.delete) {
    return deleteRequest(request, json, logger);
  }

  // Should not reach here !=(500)
  logger.error('End of script error');
  return internalServerError(msg: 'Unexpected end of script.');
}


Future<Response> postRequest(
  Request request,
  Map<String, Object> json,
  RequestLogger logger,
) async {
  /// POST

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
  final checkedUserList = userList.cast<Map<String, Object>>();

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
    try {
      await auth.createUser(userRequestList[i]);
      await firestore.collection(usersCollection).doc(ci).set(
        user['role'] == null ? {
          'first_name': firstName,
          'last_name': lastName,
        } : {
          'first_name': firstName,
          'last_name': lastName,
          'role': user['role'],
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


Future<Response> deleteRequest(
  Request request,
  Map<String, Object> json,
  RequestLogger logger,
) async {
  /// DELETE

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
    // Classes/students delete
    await userSeekAndDestroy(ci);
  }

  // Returns appropiate response
  logger.normal('users deleted: $userList');
  return Response(statusCode: 204);
}
