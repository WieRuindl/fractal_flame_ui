import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fractal_flame/id_generator.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader_web/image_downloader_web.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // var generateId = await IdGenerator.generateId();
  // var url = Uri.http('10.0.2.2:8080', '/generate/411/866/$generateId');
  // var url = Uri.http('10.0.2.2:8080', '/generate/822/1732/$generateId');

  // var url = Uri.http('10.0.2.2:8080', '/generate/4680/10128/FM429J756L');

  runApp(MyApp());
}

Future<ui.Image> decodeImageFromUint8List(Uint8List imageData) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(imageData, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ui.Image? image;

  Uint8List? uint8List;

  @override
  Widget build(BuildContext context) {
    // print(MediaQuery.of(context).size.width);
    // print(MediaQuery.of(context).size.height);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
          child: Column(
            children: [
              TextButton(
                  onPressed: () async {
                    // var url = Uri.http('10.0.2.2:8080', '/generate/400/600/0');
                    var url = Uri.http('localhost:8080', '/generate/400/600/2/0');
                    print(url.toString());
                    var response = await http.get(url);
                    print("got response");

                    final Map<String, dynamic> data = json.decode(response.body);
                    final String base64Image = data['image'];
                    final Uint8List imageBytes = base64Decode(base64Image);
                    final ui.Image image = await decodeImageFromUint8List(imageBytes);
                    setState(() {
                      uint8List = imageBytes;
                      this.image = image;
                    });
                  },
                  child: const Text("Get Image"),
              ),
              if (image != null)
                Column(
                  children: [
                    RawImage(
                      image: image,
                      width: 400,
                      height: 600,
                      fit: BoxFit.fill,
                    ),
                    TextButton(
                        onPressed: () async {
                          // await WebImageDownloader.downloadImageFromUInt8List(uInt8List: uint8List!);
                          downloadImage(uint8List!);

                          // String? outputFilePath = await _pickSaveLocation();
                          // if (outputFilePath != null) {
                          //   final file = File(outputFilePath);
                          //   await file.writeAsBytes(uint8List!);
                          // }
                        },
                        child: const Text("Download"),
                    ),
                  ],
                )
            ],
          )

        )
      ),
    );
  }

  void downloadImage(Uint8List imageBytes) {
    final base64 = base64Encode(imageBytes);
    final anchor = html.AnchorElement(
      href: 'data:image/png;base64,$base64',
    )..setAttribute("download", "downloaded_image.png")
      ..click();
  }

  Future<String?> _pickSaveLocation() async {
    String? outputPath;
    try {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Image As...',
        fileName: 'downloaded_image.png', // Default file name
      );
    } catch (e) {
      print("Error choosing save location: $e");
    }
    return outputPath;
  }
}
