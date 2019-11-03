import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

abstract class Authenticator {
  Observable<bool> authenticated;
}

class AuthenticatorImpl extends Authenticator {

  final FirebaseAuth _firebaseAuth;

  // ignore: close_sinks
  BehaviorSubject<bool> _authenticationState = BehaviorSubject.seeded(false);

  AuthenticatorImpl(this._firebaseAuth) {
    Observable(_firebaseAuth.currentUser().asStream())
        .flatMap((user) => user != null ? Observable.just(user) : _firebaseAuth.signInAnonymously().asStream().map((authResult) => authResult.user))
        .flatMap((user) => user != null ? _firebaseAuth.onAuthStateChanged.map((user) => user != null) : Observable.just(false))
        .listen((authenticated) => _authenticationState.value = authenticated);
  }

  @override
  Observable<bool> get authenticated => _authenticationState;
}