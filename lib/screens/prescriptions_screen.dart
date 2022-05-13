import 'package:flutter/material.dart';
import '/screens/info_screen.dart';
import '/services/authentication.dart';
import '/services/domain.dart';
import '/services/navigation.dart';

class PrescriptionsScreen extends StatelessWidget implements Screen {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  Page get navPage => PlainPage(key: UniqueKey(), child: this);

  @override
  Widget build(BuildContext context) {
    return Auth().hasSignedInUser
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Prescription History'),
              centerTitle: false,
              backgroundColor: const Color.fromARGB(255, 0, 129, 194),
            ),
            body: SafeArea(
              child: FutureBuilder<List<Prescription>>(
                future:
                    Repository().userPrescriptions(user: Auth().signedInUser!),
                builder: (context, prescriptionsData) {
                  final prescriptions = prescriptionsData.data ?? [];

                  return ListView.builder(
                    itemBuilder: (context, index) => Card(
                      color: Colors.red.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(prescriptions[index].drug.name),
                      ),
                    ),
                    itemCount: prescriptions.length,
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
