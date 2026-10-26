import 'package:convertify/core/logger.dart';
import 'package:flutter/services.dart';

/// A tap on the home-screen widget: open the file picker, limited to [from]
/// with [to] preselected for the quick conversions.
class WidgetLaunch {
  final String? from;
  final String? to;
  const WidgetLaunch({this.from, this.to});

  factory WidgetLaunch.fromMap(Map map) =>
      WidgetLaunch(from: map['from'] as String?, to: map['to'] as String?);
}

/// Widget taps from Android (ConvertWidgetProvider.kt, via MainActivity).
class WidgetLaunches {
  static const _channel = MethodChannel("convertify/widget");

  /// Calls [onLaunch] for the tap that started the app, if any, and for every
  /// tap while it runs. Call once the first frame is up.
  static Future<void> listen(void Function(WidgetLaunch) onLaunch) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "launch") {
        onLaunch(WidgetLaunch.fromMap(call.arguments as Map));
      }
    });
    try {
      final initial = await _channel.invokeMethod<Map>("takeLaunch");
      if (initial != null) onLaunch(WidgetLaunch.fromMap(initial));
    } on MissingPluginException {
      // No widget on this platform.
    } catch (e) {
      logger.w("Could not read the widget launch: $e");
    }
  }
}
