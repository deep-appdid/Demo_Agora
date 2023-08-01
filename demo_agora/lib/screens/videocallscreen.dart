import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // Instantiate the client
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
        appId: "e6e6d8707f6343d9a5c002c51c6a00cc",
        channelName: "voice",
        tempToken:
            "007eJxTYLi3+H2uy9r11+8X80tGVX2eZ7Nqhv6E0p6GSIGjfdNLN5gqMKSapZqlWJgbmKeZGZsYp1gmmiYbGBglmxommyUaGCQnH7hzIqUhkJHhfxQXKyMDBIL4rAxl+ZnJqQwMAOonIYk="),
  );

// Initialize the Agora Engine
  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              client: client,
              layoutType: Layout.floating,
              enableHostControls: true, // Add this to enable host controls
            ),
            AgoraVideoButtons(
              client: client,
            ),
          ],
        ),
      ),
    );
  }
}
