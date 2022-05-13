import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart' hide Notification;
import '/screens/info_screen.dart';
import '/services/authentication.dart';
import '/services/domain.dart';
import '/services/navigation.dart';

class NotificationsScreen extends StatelessWidget implements Screen {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Page get navPage => PlainPage(key: UniqueKey(), child: this);

  @override
  Widget build(BuildContext context) {
    return Auth().hasSignedInUser
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              centerTitle: false,
              backgroundColor: const Color.fromARGB(255, 0, 129, 194),
            ),
            body: SafeArea(
              child: StreamBuilder<List<Notification>>(
                stream: Repository()
                    .userNotificationsStream(user: Auth().signedInUser!),
                builder: (context, snapshot) {
                  final notifications = snapshot.data ?? [];

                  return Accordion(
                    maxOpenSections: 1,
                    paddingListHorizontal: 15.0,
                    children: notifications
                        .map(
                          (notification) => AccordionSection(
                            headerBackgroundColor: notification.hasBeenRead
                                ? const Color.fromARGB(255, 0, 129, 194)
                                : const Color.fromARGB(255, 220, 23, 47),
                            contentBorderColor: notification.hasBeenRead
                                ? const Color.fromARGB(255, 0, 129, 194)
                                : const Color.fromARGB(255, 220, 23, 47),
                            header: Text(
                              notification.subject,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            headerPadding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 15.0),
                            content: Text(notification.body),
                            onCloseSection: () {
                              Repository().markUserNotificationRead(
                                user: Auth().signedInUser!,
                                notification: notification,
                              );
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          )
        : const InfoScreen(
            child: Center(
              child: Text('Error! Unauthenticated User.'),
            ),
          );
  }
}
