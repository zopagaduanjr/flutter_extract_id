import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExtractIDScreen extends StatefulWidget {
  const ExtractIDScreen({Key? key}) : super(key: key);

  @override
  State<ExtractIDScreen> createState() => _ExtractIDScreenState();
}

class _ExtractIDScreenState extends State<ExtractIDScreen> {
  String? idImagePath;
  List<String> textsProcessed = [];

  void camera() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      return;
    }

    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    try {
      bool success = await EdgeDetection.detectEdge(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning',
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      if (success) {
        setState(() {
          idImagePath = imagePath;
        });
        processImage(imagePath);
      }
    } catch (e) {
      print(e);
    }
  }

  void processImage(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    List<String> texts = [];
    for (TextBlock block in recognizedText.blocks) {
      texts.add(block.text);
    }
    setState(() {
      textsProcessed = texts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Process ID"),
      ),
      body: Center(
          child: idImagePath == null
              ? const Text("Tap on the camera button to scan ID")
              : Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 5),
                      child: Text(
                        "Scanned photo",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Flexible(child: Image.file(File(idImagePath!))),
                    Expanded(
                      child: ListView.builder(
                        itemCount: textsProcessed.length,
                        itemBuilder: (_, index) {
                          return ListTile(
                            title: Text(textsProcessed[index]),
                          );
                        },
                      ),
                    ),
                  ],
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: camera,
        tooltip: 'Camera',
        child: const Icon(Icons.camera),
      ),
    );
  }
}
