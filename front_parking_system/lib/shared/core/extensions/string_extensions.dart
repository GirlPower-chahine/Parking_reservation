extension AuthValidationExtensions on String {
  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(this);
  }

  bool isValidUsername() {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(this);
  }
}