import 'package:flutter/material.dart';
import '/services/navigation.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    OpenScreens().addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 0, 129, 194);

    return MaterialApp(
      title: 'MediAid',
      home: BakedNavigator(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(24),
            ),
            backgroundColor: MaterialStateProperty.all(primaryColor),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
      ),
    );
  }
}
