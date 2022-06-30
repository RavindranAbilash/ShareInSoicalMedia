import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("share"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            buildImage(),
            const SizedBox(
              height: 32,
            ),
            FlatButton(
              color: Colors.teal,
              textColor: Colors.white,
              onPressed: () async {
                final image = await controller.capture();
                if (image == null) return;

                await saveImage(image);
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            FlatButton(
              color: Colors.teal,
              textColor: Colors.white,
              onPressed: () async {
                final image = await controller.captureFromWidget(buildImage());
                if (image == null) return;

                await saveImage(image);
                saveAndShare(image);
              },
              child: const Text(
                'Share',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future saveAndShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path]);
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll(':', '_');
    final name = "screenshot_$time";
    final result = await ImageGallerySaver.saveImage(bytes, name: name);

    return result['filePath'];
  }

  Widget buildImage() => Image.network(
        'https://www.psdstack.com/wp-content/uploads/2019/08/copyright-free-images-750x420.jpg',
        fit: BoxFit.cover,
      );
}
