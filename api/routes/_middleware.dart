import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';
//import 'package:dart_frog_request_logger/log_formatters.dart';


/// Thiss middleware defines the manual logger.
/// I used a customLogger but there is built-in ones like
/// formatSimpleLog() and
/// formatCloudLoggingLog()
/// Mine's have colors though...


Handler middleware(Handler handler) {
  return handler.use(
   provider<RequestLogger>(
      (context) => RequestLogger(
        headers: context.request.headers,
        logFormatter: customLogger(),
      ),
    ),
  );
}


final redAnsi = String.fromCharCodes([27, 91, 51, 49, 109]);
final blueAnsi = String.fromCharCodes([27, 91, 51, 52, 109]);
final yellowAnsi = String.fromCharCodes([27, 91, 51, 51, 109]);

final resetAnsi = String.fromCharCodes([27, 91, 48, 109]);


LogFormatter customLogger() => ({
  required Severity severity,
  required String message,
  required Map<String, String?> headers,
  Map<String, dynamic>? payload,
  Map<String, dynamic>? labels,
  bool? isError,
  Chain? chain,
  Frame? stackFrame,
}) {
  if (severity == Severity.error) {
    return '$redAnsi<ERROR>$resetAnsi $message';
  } else if (severity == Severity.warning) {
    return '$yellowAnsi<WARNING>$resetAnsi $message';
  } else if (severity == Severity.info) {
    return '$blueAnsi<INFO>$resetAnsi $message';
  } else {
    return '<LOG> $message';
  }
};
