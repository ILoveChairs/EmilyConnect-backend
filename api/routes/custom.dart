// ignore_for_file: dead_code, unused_import

import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_frog/dart_frog.dart';

import '../utils/firebase.dart';
import '../utils/firestore_names.dart';

Future<Response> onRequest(RequestContext context) async {
  /// PATCH /custom
  /// Custom operations endpoint
  /// should be disabled at production

  const disabled = true;

  // Method should be patch
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: 444);
  }

  // If disabled == true throw 444
  if (disabled) {
    return Response(statusCode: 444);
  }

  // Custom code
  /*
  // * add new class
  const name = 'class 3';
  const schedules = [{
    'day': 'Tuesday',
    'start': '8:30',
    'end': '10:30',
  }, {
    'day': 'Wednesday',
    'start': '13:30',
    'end': '15:30',
  },];
  const teacher = {
    'ci': '77777777',
    'first_name': 'teacher',
    'last_name': 'three',
  };

  await firestore.collection('classes').doc(name).set({
    'schedules': schedules,
    'teacher': teacher,
  },);
  */

  /*
  // * add users to class
  const userCIs = [
    '33330001',
    '33330002',
    '33330003',
    '33330004',
    '33330005',
    '33330006',
    '33330007',
    '33330008',
    '33330009',
    '33330010',
  ];

  const className = 'class 3';

  for (final ci in userCIs) {
    final user = await firestore.collection(usersCollection).doc(ci).get();
    if (user.exists) {
      await firestore.collection('classes/$className/students').doc(ci).set(user.data()!);
    }
  }
  */


  return Response();
}
