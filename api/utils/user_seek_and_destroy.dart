

import 'dart:async';

import 'package:dart_firebase_admin/firestore.dart';

import './firebase.dart';
import './firestore_names.dart';


Future<List<DocumentReference<Map<String, Object?>>>>
userSeek(String ci) async {
  return (await firestore.collection(coursesCollection).get())
    .docs.map((doc) => firestore.collection('${doc.ref.path}/Students').doc(ci))
    .toList();
}


Future<void> userSeekAndDestroy(String ci) async {
  final courses = await userSeek(ci);
  for (final doc in courses) {
    unawaited(doc.delete());
  }
}


Future<void> userSeekAndUpdate(String ci, Map<String, dynamic> data) async {
  final courses = await userSeek(ci);
  for (final doc in courses) {
    unawaited(doc.update(data));
  }
}
