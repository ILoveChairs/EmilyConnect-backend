import 'dart:io';
import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

/// 
/// Instanciates firebase connections.
/// 
/// DO NOT PUSH "./private_key.json", even if it is on .gitignore double check
/// that it is not going to end up on github.
/// 
/// If you do not have the file, you can download it (with care)
/// in the firebase app in the gear top left, users and permissions,
/// account services, firebase admin key, generate new private key.
/// 
/// For more information about the sdk being used for the connection:
/// https://github.com/invertase/dart_firebase_admin?tab=readme-ov-file#connecting-to-the-sdk
/// 

final admin = FirebaseAdminApp.initializeApp(
  'emilyconnect-6e047',
  Credential.fromServiceAccount(
    File('./private_key.json'),
  ),
);

final firestore = Firestore(admin);
final auth = Auth(admin);
