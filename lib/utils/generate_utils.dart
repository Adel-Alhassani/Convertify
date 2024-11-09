class GenerateUtils {
  static generateIdWithDate(String name) {
    DateTime now = DateTime.now();
    String date =
        "${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}";
    return "${name}_$date";
  }
}
