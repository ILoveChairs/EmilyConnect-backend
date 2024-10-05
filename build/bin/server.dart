// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal, inference_failure_on_untyped_parameter

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/user/multiple.dart' as user_multiple;
import '../routes/user/index.dart' as user_index;


void main() async {
  final address = InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  createServer(address, port);
}

Future<HttpServer> createServer(InternetAddress address, int port) async {
  final handler = Cascade().add(buildRootHandler()).handler;
  final server = await serve(handler, address, port);
  print('\x1B[92m✓\x1B[0m Running on http://${server.address.host}:${server.port}');
  return server;
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..mount('/user', (context) => buildUserHandler()(context as RequestContext));
  return pipeline.addHandler(router);
}

Handler buildUserHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/multiple', (context) => user_multiple.onRequest(context as RequestContext,))..all('/', (context) => user_index.onRequest(context as RequestContext,));
  return pipeline.addHandler(router);
}

