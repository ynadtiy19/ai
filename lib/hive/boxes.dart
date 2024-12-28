import 'package:ai/constants/constants.dart';
import 'package:ai/hive/chat_history.dart';
import 'package:ai/hive/settings.dart';
import 'package:ai/hive/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  // get the chat history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  // get settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
