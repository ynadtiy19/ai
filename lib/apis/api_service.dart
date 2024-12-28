import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import '../models/message.dart';

class ApiService {
  static String get apiKey => dotenv.env['API_KEY'] ?? 'API_KEY not found';
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? 'GEMINI_API_KEY not found';
  late final GenerativeModel _geminiModel;

  ApiService() {
    if (geminiApiKey.isEmpty || geminiApiKey == 'GEMINI_API_KEY not found') {
      throw Exception(
          'Gemini API key is missing. Please set the GEMINI_API_KEY environment variable.');
    }
    _geminiModel =
        GenerativeModel(model: 'gemini-pro-vision', apiKey: geminiApiKey);
  }

  Future<String?> generateText(String prompt, {List<Message>? history}) async {
    try {
      final content = [
        if (history != null)
          ...history.map((message) => Content.text(message.message.toString())),
        Content.text(prompt),
      ];
      final response = await _geminiModel.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error generating text: $e');
      return null;
    }
  }

  Future<String?> generateTextWithImage(String prompt, File imageFile, {List<Message>? history}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final content = [
        if (history != null)
          ...history.map((message) => Content.text(message.message.toString())),
        Content.multi([
          TextPart(prompt),
          DataPart('image/*', imageBytes),
        ]),
      ];
      final response = await _geminiModel.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error generating text with image: $e');
      return null;
    }
  }

  Future<String?> generateTextWithVideo(String prompt, File videoFile, {List<Message>? history}) async {
    try {
      final videoBytes = await videoFile.readAsBytes();
      final content = [
        if (history != null)
          ...history.map((message) => Content.text(message.message.toString())),
        Content.multi([
          TextPart(prompt),
          DataPart('video/*', videoBytes),
        ]),
      ];
      final response = await _geminiModel.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error generating text with video: $e');
      return null;
    }
  }

  Future<String?> generateMultimodalResponse({
    required String prompt,
    File? imageFile,
    File? videoFile,
    List<Message>? history,
  }) async {
    try {
      final List<Content> content = [];
      
      // Add conversation history if available
      if (history != null) {
        content.addAll(history.map((message) => Content.text(message.message.toString())));
      }

      // Add current message with any media
      final parts = <Part>[TextPart(prompt)];
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        parts.add(DataPart('image/*', imageBytes));
      } else if (videoFile != null) {
        final videoBytes = await videoFile.readAsBytes();
        parts.add(DataPart('video/*', videoBytes));
      }
      content.add(Content.multi(parts));

      final response = await _geminiModel.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error generating multimodal response: $e');
      return null;
    }
  }

  Future<String?> generateTextWithContext(
      String prompt, List<Message> history) async {
    try {
      final content = [
        ...history.map((message) => Content.text(message.message.toString())),
        Content.text(prompt),
      ];
      final response = await _geminiModel.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error generating text with context: $e');
      return null;
    }
  }
}
