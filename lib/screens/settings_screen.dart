import 'package:flutter/material.dart';
import '/screens/menu_screen.dart';
import '/screens/info_screen.dart';
import '/services/authentication.dart';
import '/services/domain.dart';
import '/services/navigation.dart';

class SettingsScreen extends StatefulWidget implements Screen {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Page get navPage => PlainPage(key: UniqueKey(), child: this);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  String? name = Auth().signedInUser?.name;

  bool updating = false;

  @override
  Widget build(BuildContext context) {
    return Auth().hasSignedInUser
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              centerTitle: false,
              backgroundColor: const Color.fromARGB(255, 0, 129, 194),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 15.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                        },
                        keyboardType: TextInputType.text,
                        cursorColor: const Color.fromARGB(255, 0, 129, 194),
                        style: const TextStyle(fontSize: 16),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          labelText: 'Name:',
                          labelStyle: TextStyle(fontSize: 14.0),
                          floatingLabelStyle: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (!updating) {
                                    updating = true;

                                    await Repository().updateUserName(
                                        user: Auth().signedInUser!,
                                        newName: name!);

                                    await Repository().createUserNotification(
                                        user: Auth().signedInUser!,
                                        subject: "Name updated to $name",
                                        body: "Name updated to $name");

                                    await Auth().reloadUser();

                                    OpenScreens()
                                        .putAndFocus(const MenuScreen());
                                  }
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 220, 23, 47),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                  const Size.fromHeight(50.0),
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
