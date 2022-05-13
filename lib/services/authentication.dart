import 'package:firebase_auth/firebase_auth.dart';
import '/screens/auth_screen.dart';
import '/screens/menu_screen.dart';
import '/services/navigation.dart';
import '/services/domain.dart' as domain;

class Auth {
  static Auth? _cachedObject;

  domain.User? _user;

  bool _userCreated = false;

  factory Auth() {
    _cachedObject ??= Auth._internal();

    return _cachedObject as Auth;
  }

  Auth._internal() {
    FirebaseAuth.instance.authStateChanges().listen((User? authUser) async {
      if (authUser != null) {
        var user = await domain.Repository().user(id: authUser.uid);

        // Create User if doesn't exist
        if (user == null && !_userCreated) {
          await domain.Repository().createUser(
            id: authUser.uid,
            name: (authUser.displayName != null)
                ? authUser.displayName as String
                : 'Anonymous User',
            email: (authUser.email != null)
                ? authUser.email as String
                : throw StateError('The email is unset in the Firebase User'),
          );

          user = (await domain.Repository().user(id: authUser.uid))!;

          await domain.Repository().createUserNotification(
            user: user,
            subject: "Welcome!",
            body: 'MediAid is your smart first-aid assistant. '
                'Need quick relief from a headache or stomach pain? '
                'Look no further! '
                'Simply chat with our smart bot for an FDA approved prescription. '
                'The app monitors also suggests and helps you to easily schedule'
                'an appointment with a certified doctor for a proper diagnosis.',
          );

          _userCreated = true;
        }

        _user = user;

        OpenScreens().putAndFocus(const MenuScreen());
      } else {
        _user = null;

        _userCreated = false;

        OpenScreens().putAndFocus(const AuthScreen());
      }
    });
  }

  domain.User? get signedInUser => _user;

  bool get hasSignedInUser => _user != null;

  Future<void> signOutUser() async {
    if (!hasSignedInUser) {
      throw StateError('Auth Exception. No user signed in.');
    }

    await FirebaseAuth.instance.signOut();
  }

  Future<void> reloadUser() async {
    if (_user == null) {
      throw 'No user is signed in!';
    }

    _user = await domain.Repository().user(id: _user!.id);
  }
}
