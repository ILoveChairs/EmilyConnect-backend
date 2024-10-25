import 'firebase.dart';
import 'firestore_names.dart';


class UserData {
  UserData(this.firstName, this.lastName, {this.role});
  UserData.fromJson(Map<String, dynamic> json)
    : firstName = json['first_name'] as String,
      lastName = json['last_name'] as String,
      role = json['role'] as String?;

  final String firstName;
  final String lastName;
  final String? role;
}


class TimedUser {
  TimedUser(this.ci, {required this.exists, this.userData});
  final createdAt = DateTime.now();
  final bool exists;
  final String ci;
  UserData? userData;
}


class CachedUsers {
  CachedUsers();
  static const limit = 100;
  static const timeLimit = Duration(minutes: 1);
  final cache = <TimedUser>[];

  // Checks if ci in cache, returns index !=(-1)
  int getIndexOfFirstMatch(String ci) {
    for (var i = 1; i < cache.length; i++) {
      if (cache[i].ci == ci) {
        return i;
      }
    }

    return -1;
  }

  /// Adds a user to cache
  TimedUser add(
    String ci, 
    { required bool exists, Map<String, dynamic>? incomingUserData, }
  ) {
    final user = TimedUser(ci, exists: exists);
    if (exists) {
      user.userData = UserData.fromJson(incomingUserData!);
    }
    final repeat = getIndexOfFirstMatch(ci);
    if (repeat != -1) {
      cache
        ..removeAt(repeat)
        ..insert(0, user);
    } else {
      if (cache.length + 1 == limit) {
        cache.removeLast();
      }
      cache.insert(0, user);
    }
    return user;
  }

  /// Checks cache, if not in there or outdated calls firestore
  Future<TimedUser> get(String ci) async {
    // Cache check
    final repeat = getIndexOfFirstMatch(ci);

    // Cache hit
    if (repeat != -1) {
      final cachedUser = cache.elementAt(repeat);
      if ((DateTime.now().difference(cachedUser.createdAt)) > timeLimit) {
        print('-- CACHE HIT --');
        return cachedUser;
      }
      print('-- HIT BUT OUTDATED --');
    }

    // Cache miss
    print('-- CACHE MISS --');
    final doc = await firestore.collection(usersCollection).doc(ci).get();
    final userData = doc.data();
    if (doc.exists) {
      return add(ci, incomingUserData: userData, exists: true);
    } else {
      return add(ci, exists: false);
    }
  }
}

final cachedUsers = CachedUsers();
