import 'package:flutter/material.dart';
import 'package:ai/themes/my_theme.dart';
import 'package:ai/providers/chat_provider.dart';
import 'package:ai/providers/settings_provider.dart';
import 'package:ai/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await ChatProvider.initHive();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ChatProvider()),
      ChangeNotifierProvider(create: (context) => SettingsProvider()),
    ],
    child: const AiApp(),
  ));
}

class AiApp extends StatefulWidget {
  const AiApp({super.key});

  @override
  State<AiApp> createState() => _AiAppState();
}

class _AiAppState extends State<AiApp> {
  @override
  void initState() {
    setTheme();
    super.initState();
  }

  void setTheme() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.getSavedSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Assistant',
      theme:
          context.watch<SettingsProvider>().isDarkMode ? darkTheme : lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
