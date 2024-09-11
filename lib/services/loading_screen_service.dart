import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoadingScreenService extends StatefulWidget {
  final Function onComplete;
  const LoadingScreenService({super.key, required this.onComplete});

  @override
  LoadingScreenServiceState createState() => LoadingScreenServiceState();
}

class LoadingScreenServiceState extends State<LoadingScreenService>
    with SingleTickerProviderStateMixin {
  String generatedMessage = "Initializing...";
  List<List<int>> frames = [];
  GlobalKey repaintKey = GlobalKey();
  File? gifFile;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    // Set up the animation controller and bouncing effect
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: -300, end: 0)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_controller);
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // New User - Generate welcome message using ChatGPT
        generatedMessage =
            await generateMessageFromChatGPT("Welcome to SOKONI'S!") ??
                "Welcome to SOKONI'S!";
      } else {
        // Registered User - Fetch user data and personalize message
        Map<String, dynamic> userData = await fetchUserData(user.uid);
        String name = userData['name'] ?? "User";
        generatedMessage =
            await generateMessageFromChatGPT("Welcome back, $name!") ??
                "Welcome back, $name!";
      }

      setState(() {});

      // Capture animation frames and save the GIF
      await captureAnimationFrames();
      gifFile = await saveGif(frames);

      widget.onComplete(gifFile); // Complete after loading finishes
    } catch (e) {
      setState(() {
        generatedMessage = "Error initializing: $e";
      });
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<String?> generateMessageFromChatGPT(String prompt) async {
    try {
      String apiKey = 'your_openai_api_key'; // Replace with your API key
      final url = Uri.parse("https://api.openai.com/v1/completions");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": prompt,
          "max_tokens": 100,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['choices'][0]['text'].trim();
      } else {
        print("ChatGPT API request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("ChatGPT API request failed with error: $e");
      return null;
    }
  }

  Future<void> captureAnimationFrames() async {
    for (int i = 0; i < 30; i++) {
      await captureFrame();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> captureFrame() async {
    RenderRepaintBoundary boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();
    frames.add(pngBytes);
  }

  Future<File> saveGif(List<List<int>> frames) async {
    img.Animation gifAnimation = img.Animation();

    for (var frame in frames) {
      img.Image image = img.decodeImage(frame)!;
      gifAnimation.addFrame(image);
    }

    var gifBytes = img.encodeGif(gifAnimation as img.Image);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/logo_animation.gif';
    File gifFile = File(path);
    await gifFile.writeAsBytes(gifBytes);

    return gifFile;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              key: repaintKey,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height / 2 -
                        150 +
                        _animation.value,
                    left: MediaQuery.of(context).size.width / 2 - 150,
                    child: child!,
                  );
                },
                child: NeonTextBounce(generatedMessage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for Neon Text with bounce effect
class NeonTextBounce extends StatelessWidget {
  final String message;
  const NeonTextBounce(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 7.0,
              color: Colors.cyanAccent,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
