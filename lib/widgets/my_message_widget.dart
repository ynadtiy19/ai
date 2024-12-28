import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai/models/message.dart';
import 'package:ai/widgets/preview_images_widget.dart';
import 'package:ai/widgets/chat_video_player.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.imagesUrls.isNotEmpty)
              PreviewImagesWidget(
                message: message,
              ),
            if (message.videoPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ChatVideoPlayer(
                  videoPath: message.videoPath!,
                ),
              ),
            MarkdownBody(
              selectable: true,
              data: message.message.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
