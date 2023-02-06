import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
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
      }
    } catch (e) {
      print(e);
    }
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
