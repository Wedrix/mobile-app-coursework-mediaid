import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import '/screens/info_screen.dart';
import '/services/authentication.dart';
import '/services/navigation.dart';
import '/services/domain.dart';

class ChatScreen extends StatefulWidget implements Screen {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  @override
  Page get navPage => PlainPage(key: UniqueKey(), child: this);
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();

  bool generatingResponse = false;

  @override
  void dispose() {
    textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Auth().hasSignedInUser
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Chat'),
              centerTitle: false,
              backgroundColor: const Color.fromARGB(255, 220, 23, 47),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  StreamBuilder<List<Message>>(
                    stream: Repository()
                        .userMessagesStream(user: Auth().signedInUser!),
                    builder: (context, messagesSnapshot) {
                      final messages = messagesSnapshot.data ?? [];

                      return Expanded(
                        child: ReversibleGroupedListView(messages: messages),
                      );
                    },
                  ),
                  MessageInputCard(
                    textEditingController: textEditingController,
                    postMessage: (String text) async {
                      if (text != '') {
                        setState(() {
                          generatingResponse = true;
                          textEditingController.clear();
                        });

                        await Repository().createUserMessageAndEffectBotIntent(
                          user: Auth().signedInUser!,
                          text: text,
                          timeSent: DateTime.now(),
                        );

                        setState(() {
                          generatingResponse = false;
                        });
                      }
                    },
                    enabled: !generatingResponse,
                  ),
                ],
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

class ReversibleGroupedListView extends StatefulWidget {
  const ReversibleGroupedListView({
    Key? key,
    required this.messages,
  }) : super(key: key);
  final List<Message> messages;

  @override
  State<ReversibleGroupedListView> createState() =>
      _ReversibleGroupedListViewState();
}

class _ReversibleGroupedListViewState extends State<ReversibleGroupedListView> {
  final ScrollController scrollController = ScrollController();
  bool reversed = false;
  GroupedListOrder order = GroupedListOrder.ASC;

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!reversed) {
      SchedulerBinding.instance?.addPostFrameCallback(
        (_) {
          if (scrollController.hasClients &&
              scrollController.position.hasContentDimensions) {
            if (scrollController.position.maxScrollExtent > 0) {
              setState(() {
                reversed = true;
                order = GroupedListOrder.DESC;
              });
            }
          }
        },
      );
    }

    return GroupedListView<Message, DateTime>(
      reverse: reversed,
      order: order,
      controller: scrollController,
      useStickyGroupSeparators: true,
      floatingHeader: true,
      padding: const EdgeInsets.all(10.0),
      elements: widget.messages,
      groupBy: (message) => DateTime(
        message.timeSent.year,
        message.timeSent.month,
        message.timeSent.day,
      ),
      groupHeaderBuilder: (message) => DateTimeHeader(
        time: message.timeSent,
      ),
      itemBuilder: (context, message) => MessageCard(message: message),
    );
  }
}

class MessageInputCard extends StatelessWidget {
  const MessageInputCard({
    Key? key,
    required this.textEditingController,
    required this.postMessage,
    required this.enabled,
  }) : super(key: key);

  final TextEditingController textEditingController;

  final void Function(String text) postMessage;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: const Color.fromARGB(255, 0, 129, 194),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextField(
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.text,
            cursorColor: const Color.fromARGB(255, 0, 129, 194),
            style: const TextStyle(fontSize: 16),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: enabled ? 'Message' : 'Bot replying ...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
              enabled: enabled,
            ),
            controller: textEditingController,
            onSubmitted: postMessage,
          ),
        ),
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment:
          message.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 10.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: (3 / 5) * screenWidth),
          child: Card(
            elevation: 8,
            color: message.sentByMe
                ? const Color.fromARGB(255, 0, 129, 194)
                : const Color.fromARGB(255, 220, 23, 47),
            shape: RoundedRectangleBorder(
              borderRadius: message.sentByMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0))
                  : const BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              child: Column(
                crossAxisAlignment: message.sentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    DateFormat.Hm().format(message.timeSent),
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateTimeHeader extends StatelessWidget {
  const DateTimeHeader({Key? key, required this.time}) : super(key: key);

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Card(
          elevation: 2,
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            child: Text(
              DateFormat.yMMMMd().format(time),
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
