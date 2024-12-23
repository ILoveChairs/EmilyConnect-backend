
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<void> init(InternetAddress ip, int port) async {
}


Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  /*
  final chain = Platform.script.resolve('certificates/server_chain.pem').toFilePath();
  final key = Platform.script.resolve('certificates/server_key.pem').toFilePath();

  final securityContext = SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key, password: 'VeryGoodPassword');
  */
  return serve(
    handler,
    ip,
    port,
    poweredByHeader: null,
  );
}
