import 'package:flutter/material.dart';
import 'package:fractal_flame/drawer.dart';
import 'package:fractal_flame/id_generator.dart';
import 'package:fractal_flame/my_painter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var generateId = await IdGenerator.generateId();
  runApp(MyApp(id: generateId));
}

class MyApp extends StatelessWidget {
  final String id;

  const MyApp({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    print('generateId: ${id.hashCode}');
    print('size: ${MediaQuery.of(context).size.toString()}');
    final generateImage = MyDrawer.generateImage(
        id.hashCode,
        MediaQuery.of(context).size,
    );
    print('image generated');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) => SizedBox(
            width: constraints.widthConstraints().maxWidth,
            height: constraints.heightConstraints().maxHeight,
            child: CustomPaint(painter: MyPainter(generateImage: generateImage)),
          ),
        ),
      ),
    );
  }
}
