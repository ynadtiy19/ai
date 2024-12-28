import 'package:flutter/material.dart';
import 'package:ai/models/message.dart';
import 'package:ai/providers/chat_provider.dart';
import 'package:ai/widgets/assistant_message_widget.dart';
import 'package:ai/widgets/my_message_widget.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.inChatMessages.length,
      itemBuilder: (context, index) {
        // compare with timeSent before showing the list
        final message = chatProvider.inChatMessages[index];
        return message.role.name == Role.user.name
            ? MyMessageWidget(message: message)
            : AssistantMessageWidget(message: message.message.toString());
      },
    );
  }
}
