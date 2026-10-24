import 'dart:io';

import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';

class NetworkUtils {
  static Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('api.cloudconvert.com')
          .timeout(const Duration(seconds: 5));
      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        throw NoInternetConnectionException();
      }
    } on SocketException catch (e) {
      logger.e(e);
      throw NoInternetConnectionException();
    } on Exception catch (e) {
      // TimeoutException and anything else from the lookup.
      if (e is NoInternetConnectionException) rethrow;
      logger.e(e);
      throw NoInternetConnectionException();
    }
  }
}
