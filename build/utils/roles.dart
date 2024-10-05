
bool isRole(String role) {
  /**
   * Checks if the passed role is a valid role.
   * 
   * Current valid roles are 'Admin' and 'Teacher'.
   */

  if (role == 'Admin') {
    return true;
  }

  if (role == 'Teacher') {
    return true;
  }

  return false;
}
