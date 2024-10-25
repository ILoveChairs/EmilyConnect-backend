import 'dart:async';
import 'package:dart_firebase_admin/firestore.dart';

import 'caches.dart';
import 'firebase.dart';
import 'firestore_names.dart';


/// Gets all courses, gets a reference of their students subcollections,
/// and checks whether the student exists with a get and a try catch.
Future<List<DocumentReference<Map<String, Object?>>>>
studentSeek(String ci) async {
  final refs = (await firestore.collection(coursesCollection).get())
    .docs.map((doc) => firestore.collection('${doc.ref.path}/Students').doc(ci))
    .toList();

  final outputRefs = <DocumentReference<Map<String, Object?>>>[];
  for (final ref in refs) {
    try {
      await ref.get();
      outputRefs.add(ref);
    } catch (err) {
      // Do nothing
    }
  }
  return outputRefs;
}


/// Gets all course collections that have a teacher with ci arg
Future<List<DocumentReference<Map<String, Object?>>>>
teacherSeek(String ci) async {
  return (
      await firestore.collection(coursesCollection)
      .where('teacher.ci', WhereFilter.equal, ci).get()
    )
    .docs.map((doc) => doc.ref)
    .toList();
}


/// Deletes a student in non-users collections
Future<void> studentSeekAndDestroy(String ci) async {
  final courses = await studentSeek(ci);
  for (final doc in courses) {
    unawaited(doc.delete());
  }
}

/// ! Currently not in use
/// Deletes a user in non-users collections
/// * Should be called _before_ deleting the user in users collection
Future<void> userSeekAndDelete(
  String ci,
) async {
  final cachedUser = await cachedUsers.get(ci);
  if (!cachedUser.exists) {
    return;
  }

  final role = cachedUser.userData!.role;

  if (role == null) {
    await studentSeekAndDestroy(ci);
  }
}


/// Updates students in non-users collections
Future<void> studentSeekAndUpdate(
  String ci,
  Map<String, dynamic> data,
) async {
  final courses = await studentSeek(ci);
  for (final doc in courses) {
    unawaited(doc.update(data));
  }
}


/// Updates teachers in non-users collections
Future<void> teacherSeekAndUpdate(
  String ci,
  Map<String, dynamic> data,
) async {
  final courses = await teacherSeek(ci);
  final dottedData = <String, String>{};
  if (data['first_name'] != null) {
    dottedData['teacher.first_name'] = data['first_name'] as String;
  }
  if (data['last_name'] != null) {
    dottedData['teacher.last_name'] = data['last_name'] as String;
  }
  for (final doc in courses) {
    unawaited(doc.update(dottedData));
  }
}


/// Update users in non-users collections
Future<void> userSeekAndUpdate(
  String ci,
  Map<String, dynamic> data,
) async {
  final cachedUser = await cachedUsers.get(ci);
  if (!cachedUser.exists) {
    return;
  }

  final role = cachedUser.userData!.role;

  if (role == null) {
    await studentSeekAndUpdate(ci, data);
  } else if (role == 'Teacher') {
    await teacherSeekAndUpdate(ci, data);
  }
}
