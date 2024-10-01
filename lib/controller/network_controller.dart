import 'package:convertify/service/network_service.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final NetworkService _networkService = NetworkService();
  Future<bool> isInternetConnected() async {
    if (await _networkService.checkInternet()) {
      return true;
    } else { return false;}
  }
}
