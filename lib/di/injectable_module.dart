
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/repository/firebase_message_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

@module
abstract class InjectableModule {

  @singleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging();

  @injectable
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @injectable
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @injectable
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  FirebaseMessageParser get firebaseMessageParser {
    if (Platform.isIOS) {
      return IosFirebaseMessageParser();
    } else if (Platform.isAndroid) {
      return AndroidFirebaseMessageParser();
    }

    return null;
  }


}