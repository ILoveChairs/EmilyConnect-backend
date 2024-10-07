
bool ciValidate(String ci) {
  /**
   * Validates that a uruguayan CI document is valid.
   * 
   * For more information about the validation check:
   * https://forum.openoffice.org/es/forum/viewtopic.php?t=7649
   * 
   * Might be deleted in the future.
   */

  // Check length
  if (ci.length != 8) {
    return false;
  }

  // Check if all characters are numbers and if last digit is correct
  // ! DISABLED
  /*
  const ciConstants = <int>[2, 9, 8, 7, 6, 3, 4];

  var sum = 0;
  var i = 0;
  for (; i < ciConstants.length; i++) {
    final ciDigit = int.tryParse(ci[i]);
    if (ciDigit == null) {
      return false;
    }
    sum += ciDigit * ciConstants[i];
  }

  final lastDigit = int.tryParse(ci[i]);
  if (lastDigit == null) {
    return false;
  }

  final verificatorDigit = (10 - (sum % 10)) % 10;
  if (lastDigit != verificatorDigit) {
    return false;
  }
  */

  return true;
}

/*
void main() {
  try {
    final String myCI = 'testest';
    ciValidate(myCI);
    print(myCI);
  } catch (err) {
    print(err.toString());
  }
}
*/
