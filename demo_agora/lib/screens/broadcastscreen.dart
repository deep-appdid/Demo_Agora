import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({Key? key}) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  static const String appId = "e6e6d8707f6343d9a5c002c51c6a00cc";

  String channelName = "voice";
  String token =
      "007eJxTYLi3+H2uy9r11+8X80tGVX2eZ7Nqhv6E0p6GSIGjfdNLN5gqMKSapZqlWJgbmKeZGZsYp1gmmiYbGBglmxommyUaGCQnH7hzIqUhkJHhfxQXKyMDBIL4rAxl+ZnJqQwMAOonIYk=";

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isHost =
      true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVideoSDKEngine();
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role
    if (_isHost) {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.startPreview();
    } else {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      // Set the latency level
      audienceLatencyLevel:
      AudienceLatencyLevelType.audienceLatencyLevelLowLatency;
    }

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

// Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Broadcast Streaming'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Container for the local video
              Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: _videoPanel()),
              ),
              // Radio Buttons
              Row(children: <Widget>[
                Radio<bool>(
                  value: true,
                  groupValue: _isHost,
                  onChanged: (value) => _handleRadioValueChange(value),
                ),
                const Text('Host'),
                Radio<bool>(
                  value: false,
                  groupValue: _isHost,
                  onChanged: (value) => _handleRadioValueChange(value),
                ),
                const Text('Audience'),
              ]),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Join"),
                      onPressed: () => {join()},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Leave"),
                      onPressed: () => {leave()},
                    ),
                  ),
                ],
              ),
              // Button Row ends
            ],
          )),
    );
  }

  Widget _videoPanel() {
    if (!_isJoined) {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    } else if (_isHost) {
      // Show local video preview
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      // Show remote video
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      } else {
        return const Text(
          'Waiting for a host to join',
          textAlign: TextAlign.center,
        );
      }
    }
  }

// Set the client role when a radio button is selected
  void _handleRadioValueChange(bool? value) async {
    setState(() {
      _isHost = (value == true);
    });
    if (_isJoined) leave();
  }
}
