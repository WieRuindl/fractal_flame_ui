import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:fractal_flame/id_generator.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var generateId = await IdGenerator.generateId();

  runApp(MyApp(id: generateId));
}

class MyApp extends StatefulWidget {
  final String id;
  const MyApp({super.key, required this.id});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ui.Image? image;
  Uint8List? uint8List;

  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _widthController.text = (MediaQuery.of(context).size.width ~/ 1).toString();
    _heightController.text = (MediaQuery.of(context).size.height ~/ 1).toString();
    _sidController.text = widget.id;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,),
              child: Column(
                children: [
                  const Text("Image size"),
                  Row(
                    children: [
                      const Text("width:"),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _widthController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("height:"),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("device id:"),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _sidController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      var url = Uri.https(
                      // var url = Uri.http(
                          'fractal-flame-backend.onrender.com',
                          // 'localhost:8080',
                          '/generate/${_widthController.text}/${_heightController.text}/2/${_sidController.text}'
                      );
                      print("URL: ${url.toString()}");
                      var response = await http.get(url);
                      print("got response");

                      final Map<String, dynamic> data = json.decode(response.body);
                      final String base64Image = data['image'];
                      final Uint8List uint8List = base64Decode(base64Image);
                      final ui.Image image = await decodeImageFromUint8List(uint8List);

                      setState(() {
                        this.uint8List = uint8List;
                        this.image = image;
                      });
                    },
                    child: const Text("Get Image"),
                  ),
                  SizedBox(
                    width: 200,
                    height: 300,
                    child: Column(
                      children: [
                        if (image != null)
                          ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
                            child: RawImage(
                              image: image,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        if (image != null)
                          TextButton(
                            onPressed: () async {
                              downloadImage(uint8List!);
                            },
                            child: const Text("Download"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  void downloadImage(Uint8List imageBytes) {
    final base64 = base64Encode(imageBytes);
    final newWindow = html.window.open(
        'data:image/png;base64,$base64',
        '_blank'
    );
    // html.AnchorElement(
    //   href: 'data:image/png;base64,$base64',
    // )
    //   ..setAttribute("download", "downloaded_image.png")
    //   ..click();
  }

  Future<ui.Image> decodeImageFromUint8List(Uint8List imageData) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
}
