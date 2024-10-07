import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../utils/ci.dart';
import '../../utils/firebase.dart';
import '../../utils/responses.dart';
import '../../utils/roles.dart';

Future<Response> onRequest(RequestContext context) async {
  /**
   * PATH: /user/multiple
   * ALLOWED METHODS: [POST, DELETE]
   * REQUIRED HEADERS: {'Content-Type': 'application/json'}
   * NON-SPECIFIC ERRORS: 405, 406, 401, 403, 400 => {'error': <string>}
   * 
   * => POST
   * EXPECTED POST BODY: {
   *  users: [
   *    ...
   *    {
   *      ci: <string>,
   *      first_name: <string>,
   *      last_name: <string>,
   *      role: <string> (optional)
   *    }
   *  ]
   * }
   * ON SUCCESS: 201 => {'results': {...<ci>: <string>}}
   * ON ERROR: 400 => {'error': <string>}
   * 
   * => DELETE
   * EXPECTED DELETE BODY: {
   *  users: [
   *    ...
   *    ci: <string>
   *  ]
   * }
   * ON SUCCESS: 204 => {'results': {...<ci>: <string>}}
   * ON ERROR: 400 => {'error': <string>}
   * 
   * Handles creation and deletion of multiple users.
   * However, if there is an error with any Firebase operation
   * it will be ignored. However it will be stored in a results
   * map that is passed as a response.
   * 
   * CI is checked to be a valid uruguayan document. Will probably be changed
   * in the future to not be checked.
   * 
   * If the user is created it will appear like this:
   * {'results': {...<ci>: 'User created'}}
   * 
   * If the user is deleted it will appear like this:
   * {'results': {...<ci>: 'User deleted'}}
   */

  // Rename
  final request = context.request;

  // Method check moved to be first.
  // Checks if post or delete !=(405)
  if (!(
    request.method == HttpMethod.post ||
    request.method == HttpMethod.delete
  )) {
    return methodNotAllowed();
  }

  // Check that header says body is json !=(406)
  if (request.headers['Content-Type'] != 'application/json') {
    return notAcceptable();
  }

  // TODO(ILoveChairs): Authentication check !=(401)

  // TODO(ILoveChairs): Authorization check !=(403)

  // Try to get json !=(400)
  final Map<String, dynamic> json;
  try {
    json = await request.json() as Map<String, dynamic>;
  } catch (err) {
    return badRequest();
  }

  // Redirect to function depending on method
  if (request.method == HttpMethod.post) {
    return postRequest(request, json);
  } else if (request.method == HttpMethod.delete) {
    return deleteRequest(request, json);
  }

  // Should not reach here
  return internalServerError(msg: 'End of method search');
}


Future<Response> postRequest(
  Request request,
  Map<String, dynamic> json,
) async {
  /**
   * POST
   */

  // Validate fields !=(400)
  final userList = json['users'];
  if (userList == null || userList is! List || userList.isEmpty) {
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
  }
  final checkedUserList = userList as List<Map<String, String>>;

  // Creates request to create user
  final userRequestList = <CreateRequest>[];
  for (final user in checkedUserList) {
    userRequestList.add(
      CreateRequest(
        uid: user['ci'],
        email: '${user["ci"]}@emilydickenson.com',
        password: user['ci'],
        displayName: user['ci'],
      ),
    );
  }

  // Creates list to store results of user creations
  final results = <String, String>{};

  // Calls Firebase Auth to create user !=(503)
  for (var i = 0; i < checkedUserList.length; i++) {
    final user = checkedUserList[i];
    try {
      await auth.createUser(userRequestList[i]);
      await firestore.collection('User').doc(user['ci']).set(
        user['role'] == null ? {
          'first_name': user['firstName'],
          'last_name': user['lastName'],
        } : {
          'first_name': user['firstName'],
          'last_name': user['lastName'],
          'role': user['role'],
        },
      );
      results[user['ci']!] = 'User created';
    } catch (err) {
      // Errors will be added to results
      if (err is FirebaseAuthAdminException) {
        results[user['ci']!] = err.message;
      } else if (err is FirebaseFirestoreAdminException) {
        // It will try to delete the auth user when firestore save fails
        try {
          await auth.deleteUser(user['ci']!);
        } catch (nerr) {
          // Do nothing
        }
        results[user['ci']!] = err.message;
      } else {
        results[user['ci']!] = 'Unexpected error';
      }
    }
  }

  // Returns appropiate response
  return Response.json(
    statusCode: 201,
    headers: {'Content-Type': 'application/json'},
    body: {'results': results},
  );
}


Future<Response> deleteRequest(
  Request request,
  Map<String, dynamic> json,
) async {
  /**
   * DELETE
   */

  // Validate fields !=(400)
  final userList = json['users'];
  if (userList == null || userList is! List || userList.isEmpty) {
    return badRequest();
  }
  for (final user in userList) {
    if (user is! Map) {
      return badRequest();
    }
    final ci = user['ci'];
    if (
      ci == null ||
      ci is! String
    ) {
      return badRequest();
    }
  }


  // Calls Firebase Auth to create user !=(503)
  for (var i = 0; i < userList.length; i++) {
    try {
      await auth.deleteUsers(userList as List<String>);
    } catch (err) {
      // Do nothing
      // TODO(ILoveChairs): List of errors
    }
  }

  // Returns appropiate response
  return Response(statusCode: 204);
}
