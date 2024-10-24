// ignore_for_file: dead_code, unused_import

import 'dart:ffi';

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

  /*
  // * POST list
  // Data that you should have.
  const classId = 'class 3';
  // Schedules and teacher are fields taken from class.
  const teacher = {
    'ci': '99999999',
    'first_name': 'teacher',
    'last_name': 'one',
  };
  const schedules = [{
    'day': 'Tuesday',
    'start': '8:30',
    'end': '10:30',
  }, {
    'day': 'Wednesday',
    'start': '13:30',
    'end': '15:30',
  },];

  // ? We haven't talked about how are we gonna store and get dates.
  // ? Should the teacher be able to select a date?
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  const day = 22;

  // Fields that will end up in firestore
  final schedule = schedules[0];
  final date = DateTime(year, month, day);
  final createdBy = teacher['ci'];
  // The list is a map lol
  // 0s are absent, 1s are present, 2s are late, 3s are justified
  const list = {
    '33330001': 1, '33330002': 2,
    '33330003': 0, '33330004': 1,
    '33330005': 0, '33330006': 0,
    '33330007': 1, '33330008': 0,
    '33330009': 0, '33330010': 1,
    '33330011': 1, '33330012': 1,
    '33330013': 0, '33330014': 0,
    '33330015': 3, '33330016': 1,
    '33330017': 1, '33330018': 0,
    '33330019': 0, '33330020': 1,
    '33330021': 0, '33330022': 1,
    '33330023': 1, '33330024': 1,
    '33330025': 1, '33330026': 2,
    '33330027': 0, '33330028': 0,
    '33330029': 0, '33330030': 0,
  };

  // Firestore operation.
  try {
    await firestore.collection('classes/$classId/lists').add({
      'schedule': schedule,
      'date': date,
      'created_by': createdBy,
      'list': list,
    });
  } catch (err) {
    if (err is FirebaseFirestoreAdminException) {
      // do nothing
    } else {
      // do nothing
    }
  }
  */

  /*
  // * GET lists
  // Data that you should have.
  const classId = 'class 3';

  // Firestore operation.
  final docs = (await firestore.collection('classes/$classId/lists').get()).docs;

  // Lists operations.
  // Get assistance from all lists.
  final assistanceList = docs.map((doc) => doc.data());

  /*
  // SAME AS ABOVE BUT LAME
  final assistanceList = <Map<String, dynamic>>[];
  for (final list in lists.docs) {
    final data = list.data();
    final assistance = data['list']!;
    assistanceList.add(assistance as Map<String, dynamic>);
  }
  */

  // Calculate missing num per student without cloud function
  final students = <String, double>{};
  for (final assistance in assistanceList) {
    for (final ci in assistance.keys) {
      final double assistanceValue;
      if (assistance[ci] == 0) {
        assistanceValue = 1;
      } else if (assistance[ci] == 1) {
        assistanceValue = 0;
      } else if (assistance[ci] == 2) {
        assistanceValue = 0.5;
      } else if (assistance[ci] == 3) {
        assistanceValue = 0;
      } else {
        assistanceValue = 0;
      }
      students[ci] = students[ci] == null ?
        assistanceValue :
        students[ci]! + assistanceValue;
    }
  }
  */


  /*
  // * GET classes of teacher
  // Data that you should have.
  const teacherId = '99999999';

  // Call to Firestore
  // A dot is used for values inside maps
  final teacherClasses = await firestore.collection('classes')
    .where('teacher.ci', WhereFilter.equal, teacherId).get();

  // Class operations
  final classesInfo = <String, dynamic>{};
  for (final course in teacherClasses.docs) {
    final data = course.data();
    classesInfo[course.id] = data;

    // You can use
    // final schedules = data['chedules']!;
    // final teacher = data['teacher']!;
  }
  */


  /*
  // * schedules operations
  // Data that you should have.
  const schedules = [{
    'day': 'Tuesday',
    'start': '8:30',
    'end': '10:30',
  }, {
    'day': 'Wednesday',
    'start': '13:30',
    'end': '15:30',
  },];

  // Hour operations
  int getHour(String time) {
    return int.parse(time.split(':')[0]);
  }
  int getMinute(String time) {
    return int.parse(time.split(':')[1]);
  }

  // For schedule operations we need a now.
  final rightNow = DateTime.now();
  // Transform day string to now.weekday
  int stringDayToWeekDay(String stringDay) {
    const weekDays = {
      'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
      'Friday': 5, 'Saturday': 6, 'Sunday': 7,
    };
    return weekDays[stringDay]!;
  }
  // Is in schedule's day
  bool isInSchedulesDay(DateTime now, String day) {
    // now.weekday returns an int, which 1 is monday and 7 sunday
    return now.weekday == stringDayToWeekDay(day);
  }
  // Is in schedule
  bool isInSchedule(DateTime now, Map<String, String> schedule) {
    if (!isInSchedulesDay(now, schedule['day']!)) {
      return false;
    }
    final start = schedule['start']!;
    final end = schedule['end']!;
    if (!(now.hour >= getHour(start) && now.minute >= getMinute(start))) {
      return false;
    }
    if (!(now.hour >= getHour(end) && now.minute >= getMinute(end))) {
      return false;
    }
    return true;
  }

  // Sort schedules by what is the closest one
  // It actually sorts by schedule.end
  final orderedSchedules = <Map<String, String>>[];
  final currentWeekDay = rightNow.weekday;
  final currentHour = rightNow.hour;
  final currentMinute = rightNow.minute;
  var flag = true;
  for (var i = currentWeekDay; flag;) {
    schedules.where((schedule) =>
      i == stringDayToWeekDay(schedule['day']!),
    ).toList()
    ..sort((schedule1, schedule2) {
      final endHour1 = getHour(schedule1['end']!);
      final endMinute1 = getMinute(schedule1['end']!);
      final endHour2 = getHour(schedule2['end']!);
      final endMinute2 = getMinute(schedule2['end']!);
      return ((
        (endHour1 - currentHour).abs() +
        ((endMinute1 - currentMinute).abs() / 100)
      ) - (
        (endHour2 - currentHour).abs() +
        ((endMinute2 - currentMinute).abs() / 100)
      ) * 100).toInt();
    })
    ..forEach(orderedSchedules.add);
    i--;
    if (i == 0) {
      i = 7;
    }
    if (i == currentWeekDay) {
      flag = false;
    }
  }
  */


  /*
  // * GET class students sorted by first_name
  // Data that you should have.
  const classId = 'class 3';

  final docs = (await firestore.collection('classes/$classId/students')
    .orderBy('first_name', descending: false).get()).docs;
  final students = docs.map((doc) => doc.data()).toList();
  */

  return Response();
  //return Response.json();
}
