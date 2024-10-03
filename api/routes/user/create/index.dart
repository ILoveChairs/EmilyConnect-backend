import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_frog/dart_frog.dart';

import '../../../utils/firebase.dart';

Future<Response> onRequest(RequestContext context) async {
  var res = '';
  await auth.createUser(CreateRequest(
    uid: '00000000', password: '12345678', displayName: '00000000',
    ),).then((user) {
      res = 'Success';
    }).catchError((err) {
      res = 'Error';
    });
  return Response(body: res);
}
