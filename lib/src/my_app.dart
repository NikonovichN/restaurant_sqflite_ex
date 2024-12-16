import 'package:flutter/material.dart';

import 'screen.dart';

class MyScaffoldApp extends StatelessWidget {
  const MyScaffoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Screen(),
      ),
    );
  }
}
