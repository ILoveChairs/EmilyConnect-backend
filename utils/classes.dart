
/**
 * Implements classes linked to db model.
 * All have a fromJson and a toJson method.
 * Also User has fromCSV that gets a string (with \n and \r) and returns
 * a list of User instances.
 * 
 * For reading files see dart:io and
 * https://pub.dev/packages/file_picker
 */

import 'csvToList.dart';


interface class dbDataClass {
  dbDataClass();
  dbDataClass.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}


class User extends dbDataClass {
  String? ci;
  List<String>? roles;
  String? firstName;
  String? lastName;

  User({this.ci, this.roles, this.firstName, this.lastName});

  @override
  User.fromJson(Map<String, dynamic> json)
      : ci = json['ci'],
      roles = json['roles'],
      firstName = json['firstName'],
      lastName = json['lastName'];

  @override
  Map<String, dynamic> toJson() {
    return {'ci': ci, 'roles': roles, 'firstName': firstName, 'lastName': lastName};
  }

  @override
  String toString() {
    return '<User: ${this.toJson()}>';
  }
  
  static List<User> fromCSV(String csv) {
    final usersAsMaps = csvToList(csv);
    final List<User> users = [];
    for (final userAsMap in usersAsMaps) {
      users.add(
        User(
          ci: userAsMap['ci'],
          firstName: userAsMap['firstName'],
          lastName: userAsMap['lastName']
        )
      );
    }
    return users;
  }
}


class Class extends dbDataClass {
  String? id;
  String? name;
  Map<String, Map<String, String>>? teachers;
  List<String>? schedules;

  Class({this.id, this.name, this.teachers, this.schedules});

  @override
  Class.fromJson(Map<String, dynamic> json)
      : id = json['id'],
      name = json['name'],
      teachers = json['teachers'],
      schedules = json['schedules'];

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'teachers': teachers, 'schedules': schedules};
  }

  @override
  String toString() {
    return '<Class: ${this.toJson()}>';
  }
}


class ClassList extends dbDataClass {
  String? id;
  String? schedule;
  String? createdBy;
  Map<String, int>? list;

  ClassList({this.id, this.schedule, this.createdBy, this.list});

  @override
  ClassList.fromJson(Map<String, dynamic> json)
      : id = json['id'],
      schedule = json['schedule'],
      createdBy = json['createdBy'],
      list = json['list'];

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'schedule': schedule, 'createdBy': createdBy, 'list': list};
  }

  @override
  String toString() {
    return '<ClassList: ${this.toJson()}>';
  }
}


/*
void main() {
  // You can initialize an instance with either a map (json) or
  // directly into the constructor as named args. This shows how to
  // do it with json.
  const myUserJson = {
    'ci': '00000000', 'firstName': 'Matias', 'lastName': 'Davezac'
  };
  const myClassJson = {
    'id': '1', 'name': 'B2-3',
    'teachers': {'99999999': {'firstName': 'Alberto', 'lastName': 'Santos'}}
  };
  const myClassListJson = {
    'id': '1', 'schedule': 'monday-06:30-08:00',
    'list': {'00000000': 1, '11111111': -1}
  };

  final myUser = User.fromJson(myUserJson);
  final myClass = Class.fromJson(myClassJson);
  final myClassList = ClassList.fromJson(myClassListJson);

  // The toJson methods shows all of the object's attributs as a map.
  print(myUser.toJson());
  print(myClass.toJson());
  print(myClassList.toJson());

  print('');

  // The toString methods allows for custom printing of instances.
  // It prints the name of the class and the toJson to show all attributes.
  print(myUser);
  print(myClass);
  print(myClassList);
}
*/
