import 'package:flutter/material.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key, required this.title});
  final String title;

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                child: const Text('Pick image'),
                onPressed: () => Navigator.pushNamed(context, '/drawonimage')),
            ElevatedButton(
                child: const Text('Draw'),
                onPressed: () => Navigator.pushNamed(context, '/drawcanvas')),
          ],
        ),
      ),
    );
  }
}
