

import './firebase.dart';
import './firestore_names.dart';


Future<void> userSeekAndDestroy(String ci) async {
  final courses = await firestore.collection(coursesCollection).get();
  for (final course in courses.docs) {
    final path = course.ref.path;
    await firestore.collection('$path/Students').doc(ci).delete();
  }
}
