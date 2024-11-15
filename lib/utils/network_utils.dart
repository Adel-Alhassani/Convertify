import 'dart:io';

import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';

class NetworkUtils {
  static Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      result.isEmpty && result[0].rawAddress.isEmpty;
    } on SocketException catch (e) {
      logger.e(e);
      throw NoInternetConnectionException();
    }
  }
}
