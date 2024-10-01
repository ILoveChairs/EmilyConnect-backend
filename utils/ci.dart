
bool ciValidate(String ci) {
  // Check length
  if (ci.length != 8) {
    print('checksum error: ${ci.length}');
    return false;
  }

  // Check if all characters are numbers and if last digit is correct
  // For CI check:
  // https://forum.openoffice.org/es/forum/viewtopic.php?t=7649
  const List<int> ciConstants = [2, 9, 8, 7, 6, 3, 4];

  int sum = 0;
  int i = 0;
  for (; i < ciConstants.length; i++) {
    int? ciDigit = int.tryParse(ci[i]);
    if (ciDigit == null) {
      print('non number in ci: ${ci[i]}');
      return false;
    }
    sum += ciDigit * ciConstants[i];
  }

  final int? lastDigit = int.tryParse(ci[i]);
  if (lastDigit == null) {
    print('non number in ci: ${ci[i]}');
    return false;
  }

  final int verificatorDigit = (10 - (sum % 10)) % 10;
  if (lastDigit != verificatorDigit) {
    print('verificator digit is incorrect: $verificatorDigit');
    return false;
  }

  return true;
}


class CI {
  String ci;
  CI(this.ci): assert(ciValidate(ci));

  @override
  String toString() {
    return ci;
  }
}

/*
void main() {
  try {
    final CI myCI = CI('testest');
    print(myCI);
  } catch (err) {
    print(err.toString());
  }
}
*/
