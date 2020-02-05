import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

abstract class Authenticator {
  Stream<bool> authenticated;
}

class AuthenticatorImpl extends Authenticator {

  final FirebaseAuth _firebaseAuth;

  // ignore: close_sinks
  BehaviorSubject<bool> _authenticationState = BehaviorSubject.seeded(false);

  AuthenticatorImpl(this._firebaseAuth) {
    _firebaseAuth.currentUser().asStream()
        .flatMap((user) => user != null ? Stream.value(user) : _firebaseAuth.signInAnonymously().asStream().map((authResult) => authResult.user))
        .flatMap((user) => user != null ? _firebaseAuth.onAuthStateChanged.map((user) => user != null) : Stream.value(false))
        .listen((authenticated) => _authenticationState.value = authenticated);
  }

  @override
  Stream<bool> get authenticated => _authenticationState;
}