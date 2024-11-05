import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fractal_flame/id_generator.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var generateId = await IdGenerator.generateId();
  var url = Uri.https(
      'fractal-flame-backend.onrender.com',
      '/functions');
  var response = await http.get(url);
  List<String> data = jsonDecode(response.body).cast<String>();
  runApp(MyApp(id: generateId, functions: data));
}

class MyApp extends StatefulWidget {
  final String id;
  final List<String> functions;

  const MyApp({super.key, required this.id, required this.functions});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ui.Image? image;
  Uint8List? uint8List;
  bool isLoading = false;
  String? selectedFunction;

  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _widthController.text = (MediaQuery.of(context).size.width ~/ 1).toString();
    _heightController.text = (MediaQuery.of(context).size.height ~/ 1).toString();
    _sidController.text = _sidController.text.isEmpty ? widget.id : _sidController.text;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              children: [
                const Text("Image size"),
                Row(
                  children: [
                    const Text("width:"),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
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
                        readOnly: true,
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
                Row(
                  children: [
                    const Text("function:"),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                          // hint: Text("Select an option"),
                          value: selectedFunction,
                          items: widget.functions.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFunction = newValue;
                            });
                          },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: ButtonStyle(
                    textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.black, fontSize: 16)),
                    backgroundColor: WidgetStatePropertyAll(Colors.grey.shade300),
                    fixedSize: const WidgetStatePropertyAll(Size(100, 50)),
                  ),
                  onPressed: () async {

                    setState(() {
                      this.isLoading = true;
                    });

                    var url = Uri.https(
                    // var url = Uri.http(
                        'fractal-flame-backend.onrender.com',
                        // '10.0.2.2:8080',
                        // 'localhost:8080',
                        '/generate/${_widthController.text}/${_heightController.text}/2/${_sidController.text}');
                    var response = await http.get(url);

                    final Map<String, dynamic> data = json.decode(response.body);
                    final String base64Image = data['image'];
                    final Uint8List uint8List = base64Decode(base64Image);
                    final ui.Image image = await decodeImageFromUint8List(uint8List);

                    setState(() {
                      this.uint8List = uint8List;
                      this.image = image;
                      this.isLoading = false;
                    });
                  },
                  child: const Text("Get Image"),
                ),
                const SizedBox(height: 16),
                if (isLoading) const CircularProgressIndicator(),
                if (image != null)
                  Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 100,
                        child: RawImage(
                          image: image,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.black, fontSize: 16)),
                          backgroundColor: WidgetStatePropertyAll(Colors.grey.shade300),
                          fixedSize: const WidgetStatePropertyAll(Size(100, 50)),
                        ),
                        onPressed: () async {
                          // await downloadImage(uint8List!);
                          downloadImageWeb(uint8List!);

                        },
                        child: const Text("Download"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void downloadImageWeb(Uint8List imageBytes) {
    // Convert the image bytes to Base64
    final base64Image = base64Encode(imageBytes);
    final url = 'data:image/png;base64,$base64Image';

    html.AnchorElement(href: url)
      ..setAttribute("download", "downloaded_image.png")
      ..click();
  }

  Future<ui.Image> decodeImageFromUint8List(Uint8List imageData) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
}
