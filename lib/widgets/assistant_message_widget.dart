import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ai/models/message.dart';
import 'package:ai/widgets/preview_images_widget.dart';
import 'package:ai/widgets/chat_video_player.dart';

class AssistantMessageWidget extends StatelessWidget {
  const AssistantMessageWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: message.message.toString().isEmpty
            ? const SizedBox(
                width: 50,
                child: SpinKitThreeBounce(
                  color: Colors.blueGrey,
                  size: 20.0,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
