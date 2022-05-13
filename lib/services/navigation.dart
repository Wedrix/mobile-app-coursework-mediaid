import 'package:flutter/material.dart';
import '/screens/auth_screen.dart';
import '/screens/menu_screen.dart';
import '/services/authentication.dart';

class BakedNavigator extends Navigator {
  BakedNavigator({Key? key})
      : super(
          key: key,
          pages: OpenScreens().navPages,
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            OpenScreens().removeFocused();

            return true;
          },
        );
}

class OpenScreens extends ChangeNotifier {
  factory OpenScreens() {
    _cachedObject ??= OpenScreens._internal();

    return _cachedObject as OpenScreens;
  }

  OpenScreens._internal();

  static OpenScreens? _cachedObject;

  final List<Screen> _screens = [
    if (Auth().hasSignedInUser) const MenuScreen() else const AuthScreen()
  ];

  Screen? get focused => _screens.isNotEmpty ? _screens.last : null;

  List<Page<dynamic>> get navPages =>
      _screens.map((screen) => screen.navPage).toList();

  void _focus(Type screen) {
    if (!contains(screen)) {
      throw StateError(
          'No screen of type $screen exists in OpenScreens #focus');
    }

    var screenToFocus = this.screen(screen);

    _screens.remove(screenToFocus);

    _screens.add(screenToFocus);

    notifyListeners();
  }

  void _put(Screen screen) {
    if (contains(screen.runtimeType)) {
      var index = _screens.indexOf(this.screen(screen.runtimeType));

      _screens[index] = screen;
    } else {
      _screens.add(screen);
    }
  }

  void removeFocused() {
    _screens.remove(focused);

    notifyListeners();
  }

  void putAndFocus(Screen screen) {
    _put(screen);

    _focus(screen.runtimeType);

    notifyListeners();
  }

  bool contains(Type screen) {
    return _screens.any((element) => element.runtimeType == screen);
  }

  Screen screen(Type screen) {
    if (!contains(screen)) {
      throw StateError('No screen of type $screen exists in OpenScreens #get');
    }

    return _screens.singleWhere((element) => element.runtimeType == screen);
  }
}

abstract class Screen {
  Page get navPage;
}

class PlainPage extends Page {
  const PlainPage({required key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        return child;
      },
    );
  }
}
