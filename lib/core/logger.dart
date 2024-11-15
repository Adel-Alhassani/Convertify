import 'package:logger/logger.dart';

final Logger logger = Logger(
    printer: PrettyPrinter(
        colors: true,
        errorMethodCount: 1,
        printEmojis: true,
        lineLength: 50,
        methodCount: 2));
