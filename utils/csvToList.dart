
import 'package:csv/csv.dart';

// csv package install
// https://pub.dev/packages/csv/install


List<Map<String, dynamic>> csvToList(String csv) {
  final List<List<dynamic>> data = CsvToListConverter().convert(csv);

  if (csv.length <= 1 || csv[0].length == 0) {
    return [];
  }

  final fields = data[0];
  final List<Map<String, dynamic>> jsonList = [];

  for (final row in data.sublist(1)) {
    final Map<String, dynamic> newObject = {};
    for (int i = 0; i < fields.length; i++) {
      newObject[fields[i]] = row[i];
    }
    jsonList.add(newObject);
  }

  return jsonList;
}

/*
void main() {
  final myCsv = 'name,age\r\nmatias,19\r\nnicolas,22\r\r\nagustin,18\r\nmanuel,19';
  print(csvToList(myCsv));
}
*/
