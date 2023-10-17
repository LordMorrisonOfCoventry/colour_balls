import 'package:colourballs/model/basic_game_model_provider.dart';
import 'package:colourballs/model/game_model.dart';
import 'package:colourballs/ui/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The main method to launch the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

/// The root Widget of the app.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Colour Balls',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Colors.grey.shade900),
        home: HomeView(_gameModelProvider),
      );

  /// Return other implementations of [GameModelProvider] here for testing etc.
  GameModelProvider get _gameModelProvider => BasicGameModelProvider();
}
