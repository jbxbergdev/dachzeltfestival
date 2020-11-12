import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rxdart/rxdart.dart';

abstract class Authenticator {
  Stream<bool> authenticated;
}

class AuthenticatorImpl extends Authenticator {

  final FirebaseAuth _firebaseAuth;

  // ignore: close_sinks
  BehaviorSubject<bool> _authenticationState = BehaviorSubject.seeded(false);

  AuthenticatorImpl(this._firebaseAuth) {
    _firebaseAuth.signInAnonymously().asStream()
        .flatMap((userCredential) => userCredential?.user != null ? _firebaseAuth.authStateChanges().map((user) => user != null) : Stream.value(false))
        .listen((authenticated) => _authenticationState.value = authenticated);
  }

  @override
  Stream<bool> get authenticated => _authenticationState;
}