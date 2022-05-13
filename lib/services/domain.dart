import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dialogflow_grpc/v2beta1.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:dialogflow_grpc/dialogflow_auth.dart';
import 'package:flutter/services.dart' show rootBundle;

class Repository {
  static Repository? _cachedObject;

  factory Repository() {
    _cachedObject ??= Repository._internal();

    return _cachedObject as Repository;
  }

  Repository._internal();

  final _users =
      FirebaseFirestore.instance.collection('users').withConverter<User>(
            fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
            toFirestore: (user, _) => user.toJson(),
          );

  Future<User?> user({required String id}) async =>
      (await _users.doc(id).get()).data();

  Future<List<Prescription>> userPrescriptions({required User user}) async {
    final prescriptions = FirebaseFirestore.instance
        .collection('users/${user.id}/prescriptions')
        .withConverter<Prescription>(
          fromFirestore: (snapshot, _) =>
              Prescription.fromJson(snapshot.data()!),
          toFirestore: (prescription, _) => prescription.toJson(),
        );

    return prescriptions.orderBy('timeIssued').get().then((docsSnapshot) =>
        docsSnapshot.docs.map((snapshot) => snapshot.data()).toList());
  }

  Stream<List<Message>> userMessagesStream({required User user}) {
    final messages = FirebaseFirestore.instance
        .collection('users/${user.id}/messages')
        .withConverter<Message>(
          fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
          toFirestore: (message, _) => message.toJson(),
        );

    return messages
        .orderBy('timeSent')
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) => docs.map((snapshot) => snapshot.data()).toList());
  }

  Stream<List<Notification>> userNotificationsStream({required User user}) {
    final notifications = FirebaseFirestore.instance
        .collection('users/${user.id}/notifications')
        .withConverter<Notification>(
          fromFirestore: (snapshot, _) =>
              Notification.fromJson(snapshot.data()!),
          toFirestore: (notification, _) => notification.toJson(),
        );

    return notifications
        .orderBy('timeCreated')
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) => docs.map((snapshot) => snapshot.data()).toList());
  }

  Future<void> createUser({
    required String id,
    required String name,
    required String email,
  }) async {
    final user = User(
      id: id,
      name: name,
      email: email,
    );

    await _users.doc(id).set(user);
  }

  Future<void> createUserMessageAndEffectBotIntent({
    required User user,
    required String text,
    required DateTime timeSent,
  }) async {
    final messages = FirebaseFirestore.instance
        .collection('users/${user.id}/messages')
        .withConverter<Message>(
          fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!),
          toFirestore: (message, _) => message.toJson(),
        );

    final messageDocumentReference = messages.doc();

    final message = Message(
      id: messageDocumentReference.id,
      text: text,
      timeSent: DateTime.now(),
      sentByMe: true,
    );

    await messages.doc(messageDocumentReference.id).set(message);

    final serviceAccount = ServiceAccount.fromString((await rootBundle
        .loadString('keys/google_service_account_credentials.json')));

    DialogflowGrpcV2Beta1 dialogflow =
        DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);

    DetectIntentResponse data = await dialogflow.detectIntent(text, 'en-US');

    String responseText = data.queryResult.fulfillmentText;

    if (responseText != "") {
      final responseDocumentReference = messages.doc();

      final response = Message(
        id: responseDocumentReference.id,
        text: responseText,
        timeSent: DateTime.now(),
        sentByMe: false,
      );

      await messages.doc(responseDocumentReference.id).set(response);
    }
  }

  Future<void> createUserNotification({
    required User user,
    required String subject,
    required String body,
  }) async {
    final notifications = FirebaseFirestore.instance
        .collection('users/${user.id}/notifications')
        .withConverter<Notification>(
          fromFirestore: (snapshot, _) =>
              Notification.fromJson(snapshot.data()!),
          toFirestore: (notification, _) => notification.toJson(),
        );

    final docReference = notifications.doc();

    final notification = Notification(
      id: docReference.id,
      subject: subject,
      body: body,
      timeCreated: DateTime.now(),
      hasBeenRead: false,
    );

    await notifications.doc(docReference.id).set(notification);
  }

  Future<void> markUserNotificationRead({
    required User user,
    required Notification notification,
  }) async {
    final notifications = FirebaseFirestore.instance
        .collection('users/${user.id}/notifications')
        .withConverter<Notification>(
          fromFirestore: (snapshot, _) =>
              Notification.fromJson(snapshot.data()!),
          toFirestore: (notification, _) => notification.toJson(),
        );

    final readNotification = Notification(
      id: notification.id,
      subject: notification.subject,
      body: notification.body,
      timeCreated: notification.timeCreated,
      hasBeenRead: true,
    );

    await notifications.doc(notification.id).set(readNotification);
  }

  Future<void> updateUserName({
    required User user,
    required String newName,
  }) async {
    final updatedUser = User(id: user.id, name: newName, email: user.email);

    await _users.doc(user.id).set(updatedUser);
  }
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
  final String id;
  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

class Message {
  const Message({
    required this.id,
    required this.text,
    required this.timeSent,
    required this.sentByMe,
  });
  final String id;
  final String text;
  final DateTime timeSent;
  final bool sentByMe;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      timeSent: json['timeSent'].toDate(),
      sentByMe: json['sentByMe'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'timeSent': timeSent,
        'sentByMe': sentByMe,
      };
}

class Notification {
  const Notification({
    required this.id,
    required this.subject,
    required this.body,
    required this.timeCreated,
    required this.hasBeenRead,
  });
  final String id;
  final String subject;
  final String body;
  final DateTime timeCreated;
  final bool hasBeenRead;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
        id: json['id'],
        subject: json['subject'],
        body: json['body'],
        timeCreated: json['timeCreated'].toDate(),
        hasBeenRead: json['hasBeenRead']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'body': body,
        'timeCreated': timeCreated,
        'hasBeenRead': hasBeenRead,
      };
}

class Prescription {
  const Prescription({
    required this.id,
    required this.dosage,
    required this.drug,
    required this.symptom,
    required this.timeIssued,
  });
  final String id;
  final String dosage;
  final Drug drug;
  final String symptom;
  final DateTime timeIssued;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      dosage: json['dosage'],
      drug: Drug.fromJson(json['drug']),
      symptom: json['symptom'],
      timeIssued: json['timeIssued'].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dosage': dosage,
        'drug': drug.toJson(),
        'symptom': symptom,
        'timeIssued': timeIssued
      };
}

class Drug {
  const Drug({
    required this.fdaId,
    required this.name,
  });
  final String fdaId;
  final String name;

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(fdaId: json['fdaId'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'fdaId': fdaId, 'name': name};
}
