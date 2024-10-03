import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../utils/ci.dart';
import '../../../utils/firebase.dart';

Future<Response> onRequest(RequestContext context) async {
  /**
   * 
   */

  // Rename
  final request = context.request;

  // Check that method is POST !=(405)
  if (request.method != HttpMethod.post) {
    return methodNotAllowed();
  }

  // Check that body is json with header !=(406)
  if (request.headers['Content-Type'] != 'application/json') {
    return notAcceptable();
  }

  // Try to get json !=(400)
  final Map<String, dynamic> json;
  try {
    json = await request.json() as Map<String, dynamic>;
  } catch (err) {
    return badRequest();
  }

  // Validate fields !=(400)
  final userList = json['users'];
  if (userList == null || userList is! List || userList.isEmpty) {
    return badRequest();
  }
  for (final user in userList) {
    final ci = user['ci'];
    final firstName = user['first_name'];
    final lastName = user['last_name'];
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
  }

  // Creates request to create user
  final List<CreateRequest> userRequestList = [];
  for (final user in userList) {
    userRequestList.add(
      CreateRequest(
        uid: user['ci'] as String,
        email: '${user["ci"]}@emilydickenson.com',
        password: user['ci'] as String,
        displayName: user['ci'] as String,
      ),
    );
  }

  // Calls Firebase Auth to create user !=(503)
  for (var i = 0; i < userList.length; i++) {
    try {
      await auth.createUser(userRequestList[i]);
      final user = userList[i];
      await firestore.collection('User').doc(user['ci'] as String).set({
        'first_name': user['first_name'] as String,
        'last_name': user['last_name'] as String,
      });
    } catch (err) {
      // do nothing
    }
  }

  // Returns appropiate response
  return Response(statusCode: 201);
}


/// 
/// ERROR RESPONSES
/// 


Response methodNotAllowed() {
  return Response.json(
    statusCode: 405,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'POST',
    },
    body: {'error': 'Method Not Allowed'},
  );
}


Response notAcceptable() {
  return Response.json(
    statusCode: 406,
    headers: {
      'Content-Type': 'application/json',
      'Allow': 'application/json',
    },
    body: {'error': 'Not Acceptable'},
  );
}


Response badRequest() {
  return Response.json( 
    statusCode: 400,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Bad Request'},
  );
}


Response unauthorized() {
  return Response.json(
    statusCode: 401,
    headers: {
      'Content-Type': 'application/json',
    },
    body: {'error': 'Unauthorized'},
  );
}
