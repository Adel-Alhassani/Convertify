import 'package:convertify/controller/file_controller.dart';
import 'package:get/get.dart';

class InitServices extends GetxService {
  Future<InitServices> init() async {
    Get.put(FileController());
    print("init");
    return this;
  }
}
