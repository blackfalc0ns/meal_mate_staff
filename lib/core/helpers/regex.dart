class AppRegExp {
  const AppRegExp._();

  static final RegExp name = RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]{2,50}$");
  static final RegExp email = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
  static final RegExp phone = RegExp(r'^\+?[0-9]{8,15}$');
  static final RegExp password = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[#?!@$%^&*-]).{8,}$',
  );

  static bool isNameValid(String value) => name.hasMatch(value.trim());
  static bool isEmailValid(String value) => email.hasMatch(value.trim());
  static bool isPhoneValid(String value) => phone.hasMatch(value.trim());
  static bool isPasswordValid(String value) => password.hasMatch(value);
}
