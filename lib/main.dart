import 'package:flutter/material.dart';

import 'axes_scrollbar_chart.dart';
import 'minimap_scrollbar_chart.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text('Minimap Scrollbar Chart'),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => const MinimapScrollbarChart(),
                ));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text('Scrollbar On Chart Axes'),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => const ScrollbarAxesChart(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
