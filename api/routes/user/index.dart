import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../utils/ci.dart';
import '../../utils/firebase.dart';
import '../../utils/responses.dart';

Future<Response> onRequest(RequestContext context) async {
  /**
   * PATH: /user
   * ALLOWED METHODS: [POST, DELETE]
   * REQUIRED HEADERS: {'Content-Type': 'application/json'}
   * NON-SPECIFIC ERRORS: 405, 406, 401, 403, 400 => {'error': <string>}
   * 
   * => POST
   * EXPECTED POST BODY: {
   *  ci: <string>,
   *  first_name: <string>,
   *  last_name: <string>
   * }
   * ON SUCCESS: 201
   * ON ERROR: 400, 503 => {'error': <string>}
   * 
   * => DELETE
   * EXPECTED DELETE BODY: {
   *  ci: <string>
   * }
   * ON SUCCESS: 204
   * ON ERROR: 400, 503 => {'error': <string>}
   * 
   * Handles creation and deletion of singular users.
   * Updates are not implemented yet.
   * Reads will probably not be implemented as it can be
   * directly done through Firestore.
   */

  // Rename
  final request = context.request;

  // Method check moved to be first, checks if post or delete !=(405)
  if (!(
    request.method == HttpMethod.post ||
    request.method == HttpMethod.delete
  )) {
    return methodNotAllowed();
  }

  // Check that body is json with header !=(406)
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

  // Check that method is POST
  if (request.method == HttpMethod.post) {
    return postRequest(request, json);
  } else if (request.method == HttpMethod.delete) {
    return deleteRequest(request, json);
  }

  // Should not reach here
  return Response(statusCode: 500);
}

Future<Response> postRequest(
  Request request,
  Map<String, dynamic> json,
) async {
  /**
   * POST
   * EXPECTED POST BODY: {
   *  ci: <string>,
   *  first_name: <string>,
   *  last_name: <string>
   * }
   * ON SUCCESS: 201
   * ON ERROR: 400, 503 => {'error': <string>}
   * 
   * Creates a user both in Firebase Auth and in Firestore's User collection.
   * CI is checked to be a valid uruguayan document. Will probably be changed
   * in the future to not be checked.
   */

  // Validate fields !=(400)
  final ci = json['ci'];
  final firstName = json['first_name'];
  final lastName = json['last_name'];
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
    await firestore.collection('User').doc(ci).set({
      'first_name': firstName,
      'last_name': lastName,
    });
  } catch (err) {
    return serviceUnavailable();
  }

  // Returns appropiate response
  return Response(statusCode: 201);
}


Future<Response> deleteRequest(
  Request request,
  Map<String, dynamic> json,
) async {
  /**
   * DELETE
   * EXPECTED DELETE BODY: {
   *  ci: <string>
   * }
   * ON SUCCESS: 204
   * ON ERROR: 400, 503 => {'error': <string>}
   * 
   * For now only deletes the user in Firebase Auth.
   * Later it will search all class user and list documents for the user and
   * delete them there.
   */

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
    await auth.deleteUser(ci);
  } catch (err) {
    return serviceUnavailable();
  }

  // TODO(ILoveChairs): Create user Search and Destroy

  // Returns appropiate response
  return Response(statusCode: 201);
}
