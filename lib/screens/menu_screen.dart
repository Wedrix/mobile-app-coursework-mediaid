import 'package:flutter/material.dart' hide Notification;
import 'package:mobile_app_dev_coursework/screens/info_screen.dart';
import '/services/domain.dart';
import '/services/authentication.dart';
import '/layouts/default_layout.dart';
import '/screens/settings_screen.dart';
import '/screens/notifications_screen.dart';
import '/screens/chat_screen.dart';
import '/services/navigation.dart';
import '/widgets/logo.dart';

class MenuScreen extends StatelessWidget implements Screen {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Page get navPage => PlainPage(key: UniqueKey(), child: this);

  @override
  Widget build(BuildContext context) {
    return Auth().hasSignedInUser
        ? DefaultLayout(
            child: Column(
              children: [
                const Logo(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        NavCard(
                          color: const Color.fromARGB(255, 220, 23, 47),
                          icon: Icons.question_answer_outlined,
                          text: 'Chat',
                          onTap: () {
                            OpenScreens().putAndFocus(const ChatScreen());
                          },
                        ),
                        const NotificationsNavCard(),
                        NavCard(
                          color: const Color.fromARGB(255, 0, 129, 194),
                          icon: Icons.settings_outlined,
                          text: 'Settings',
                          onTap: () {
                            OpenScreens().putAndFocus(const SettingsScreen());
                          },
                        ),
                        NavCard(
                          color: const Color.fromARGB(255, 220, 23, 47),
                          icon: Icons.logout_outlined,
                          text: 'Logout',
                          onTap: () async {
                            await Auth().signOutUser();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : const InfoScreen(
            child: Center(
              child: Text('Error! Unauthenticated User.'),
            ),
          );
  }
}

class NotificationsNavCard extends StatelessWidget {
  const NotificationsNavCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Notification>>(
        stream:
            Repository().userNotificationsStream(user: Auth().signedInUser!),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          final userUnreadNotificationsCount = notifications
              .where((notification) => !notification.hasBeenRead)
              .length;

          return (userUnreadNotificationsCount > 0)
              ? Stack(
                  fit: StackFit.loose,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: NavCard(
                        color: const Color.fromARGB(255, 0, 129, 194),
                        icon: Icons.notifications_outlined,
                        text: 'Notifications',
                        onTap: () {
                          OpenScreens()
                              .putAndFocus(const NotificationsScreen());
                        },
                      ),
                    ),
                    Positioned(
                      top: 60.0,
                      left: 60.0,
                      right: 0.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 220, 23, 47),
                        ),
                        height: 30.0,
                        width: 30.0,
                        child: Center(
                          child: Text(
                            userUnreadNotificationsCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : NavCard(
                  color: const Color.fromARGB(255, 0, 129, 194),
                  icon: Icons.notifications_outlined,
                  text: 'Notifications',
                  onTap: () {
                    OpenScreens().putAndFocus(const NotificationsScreen());
                  },
                );
        });
  }
}

class NavCard extends StatelessWidget {
  const NavCard({
    Key? key,
    required this.color,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          color: Colors.white,
          shadowColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 90.0,
              ),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
