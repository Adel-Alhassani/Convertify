class GenerateUtils {
  static int _counter = 0;

  /// Unique, sortable id such as "Convertify_20260105_093007_123_0".
  ///
  /// Every date part is zero-padded (the old version produced "111" for both
  /// Jan 11 and Nov 1) and a counter breaks ties within one millisecond.
  static String generateIdWithDate(String name, {DateTime? now}) {
    final t = now ?? DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final date = "${t.year}${two(t.month)}${two(t.day)}";
    final time =
        "${two(t.hour)}${two(t.minute)}${two(t.second)}_${t.millisecond.toString().padLeft(3, '0')}";
    return "${name}_${date}_${time}_${_counter++}";
  }
}
