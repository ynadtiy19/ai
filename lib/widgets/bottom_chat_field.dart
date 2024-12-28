import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ai/providers/chat_provider.dart';
import 'package:ai/utility/animated_dialog.dart';
import 'package:ai/widgets/preview_images_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ai/services/tts_service.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // controller for the input field
  final TextEditingController textController = TextEditingController();

  // focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  // initialize image picker
  final ImagePicker _picker = ImagePicker();

  // speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _speechState = '';
  bool _continuousListening = false;
  final TTSService _tts = TTSService();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      var available = await _speech.initialize(
        onError: (error) => setState(() {
          _speechState = 'error';
          _isListening = false;
        }),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              _speechState = '';
            });
          }
        },
      );
      if (!available) {
        setState(() => _speechState = 'not available');
      }
    } catch (e) {
      log('Speech initialization error: $e');
      setState(() => _speechState = 'error');
    }
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sentMessage(
        message: message,
        isTextOnly: isTextOnly,
      );

      // Get the latest message from the chat provider
      final messages = chatProvider.inChatMessages;
      if (messages.isNotEmpty) {
        final latestMessage = messages.last;
        if (latestMessage.message.toString().trim().isNotEmpty) {
          await _tts.speak(latestMessage.message.toString());
        }
      }
    } catch (e) {
      log('error : $e');
    } finally {
      setState(() {
        textController.clear();
        _speechState = '';
      });
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  // pick an image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  // pick a video
  Future<void> pickVideo() async {
    try {
      final pickedVideo = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (pickedVideo != null) {
        await widget.chatProvider.sendMessageWithVideo(File(pickedVideo.path));
      }
    } catch (e) {
      log('error : $e');
    }
  }

  void _listen({bool continuous = false}) async {
    if (!_isListening) {
      setState(() => _isListening = true);
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() async {
    try {
      setState(() {
        _speechState = 'listening';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            textController.text = result.recognizedWords;
          });
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          onDevice: true,
          cancelOnError: true,
        ),
      );
    } catch (e) {
      log('Speech recognition error: $e');
      setState(() {
        _speechState = 'error';
        _isListening = false;
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _continuousListening = false;
      _speechState = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Column(
      children: [
        if (_speechState.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isListening)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                Text(
                  _speechState,
                  style: TextStyle(
                    color: _speechState.startsWith('Error')
                        ? Colors.red
                        : Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).textTheme.titleLarge!.color!,
            ),
          ),
          child: Column(
            children: [
              if (hasImages) const PreviewImagesWidget(),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (hasImages) {
                        // show the delete dialog
                        showMyAnimatedDialog(
                            context: context,
                            title: 'Delete Images',
                            content:
                                'Are you sure you want to delete the images?',
                            actionText: 'Delete',
                            onActionPressed: (value) {
                              if (value) {
                                widget.chatProvider.setImagesFileList(
                                  listValue: [],
                                );
                              }
                            });
                      } else {
                        pickImage();
                      }
                    },
                    icon: Icon(
                      hasImages ? CupertinoIcons.delete : CupertinoIcons.photo,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.videocam),
                    onPressed: widget.chatProvider.isLoading ? null : pickVideo,
                  ),
                  GestureDetector(
                    onTapDown: (_) => Future.delayed(
                      const Duration(milliseconds: 500),
                      () {
                        if (mounted && !_isListening) {
                          _listen(continuous: true);
                        }
                      },
                    ),
                    onTapUp: (_) {
                      if (!_isListening) {
                        _listen(continuous: false);
                      }
                    },
                    onLongPressStart: (_) => _listen(continuous: true),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: _isListening ? Colors.red : null,
                      ),
                      onPressed: null, // Handled by GestureDetector
                    ),
                  ),
                  if (_isListening && _continuousListening)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _stopListening,
                      color: Colors.red,
                    ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: textFieldFocus,
                      controller: textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: widget.chatProvider.isLoading
                          ? null
                          : (String value) {
                              if (value.isNotEmpty) {
                                // send the message
                                sendChatMessage(
                                  message: textController.text,
                                  chatProvider: widget.chatProvider,
                                  isTextOnly: hasImages ? false : true,
                                );
                              }
                            },
                      decoration: InputDecoration.collapsed(
                          hintText: 'Enter a prompt...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.chatProvider.isLoading
                        ? null
                        : () {
                            if (textController.text.isNotEmpty) {
                              // send the message
                              sendChatMessage(
                                message: textController.text,
                                chatProvider: widget.chatProvider,
                                isTextOnly: hasImages ? false : true,
                              );
                            }
                          },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.all(5.0),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            CupertinoIcons.arrow_up,
                            color: Colors.white,
                          ),
                        )),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
