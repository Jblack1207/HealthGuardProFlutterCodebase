import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraFeedConnection {
  final RTCPeerConnection peerConnection;
  final WebSocketChannel signalChannel;

  // CHANGED: no longer final so we can create talkback later
  MediaStream? localAudioStream;

  // CHANGED: no longer final so we can create talkback later
  MediaStreamTrack? talkbackTrack;

  CameraFeedConnection({
    required this.peerConnection,
    required this.signalChannel,
    this.localAudioStream,
    this.talkbackTrack,
  });

  // ADDED
  Future<void> ensureTalkbackTrack() async {
    if (talkbackTrack != null) {
      print('Talkback track already exists');
      return;
    }

    print('Creating local audio stream');
    localAudioStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });

    talkbackTrack = localAudioStream!.getAudioTracks().first;
    talkbackTrack!.enabled = false;

    print('Adding talkback track');
    await peerConnection.addTrack(talkbackTrack!, localAudioStream!);

    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);

    print('Sending renegotiation offer');
    signalChannel.sink.add(jsonEncode({
      'type': offer.type,
      'sdp': offer.sdp,
    }));
  }

  Future<void> setTalkbackEnabled(bool enabled) async {
    talkbackTrack?.enabled = enabled;
    print('Talkback enabled: $enabled');
  }
}

class CameraFeedService {
  static const Map<String, dynamic> rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  static Future<CameraFeedConnection> connect({
    required String deviceId,
    required bool Function() isClosed,
    required bool Function() isMounted,
    required Future<void> Function(MediaStream stream) onVideoStream,
    required void Function() onAudioTrack,
    required void Function(String message) onAnswerReceived,
    required void Function(String message) onTrackDebug,
    required void Function(String error) onSocketError,
    required void Function() onSocketDoneWithoutStream,
    required bool Function() hasRendererStream,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No logged-in Firebase user');
    }

    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception('Failed to get Firebase token');
    }

    final wsUrl =
        'wss://api-appname.duckdns.org/webrtc/view/$deviceId?token=${Uri.encodeComponent(token)}';

    final peerConnection = await createPeerConnection(rtcConfig);

    late WebSocketChannel signalChannel;

    peerConnection.onTrack = (RTCTrackEvent event) async {
      if (isClosed()) return;

      onTrackDebug('Track received: ${event.track.kind}');
      onTrackDebug('Streams count: ${event.streams.length}');

      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        await onVideoStream(event.streams[0]);
      }

      if (event.track.kind == 'audio') {
        onAudioTrack();
      }
    };

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      if (isClosed()) return;

      signalChannel.sink.add(
        jsonEncode({
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        }),
      );
    };

    await peerConnection.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.RecvOnly,
      ),
    );

    await peerConnection.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.RecvOnly,
      ),
    );

    signalChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

    signalChannel.stream.listen(
          (rawMessage) async {
        if (isClosed()) return;

        final message = jsonDecode(rawMessage as String);

        if (message['type'] == 'answer') {
          onAnswerReceived('Received answer');
          await peerConnection.setRemoteDescription(
            RTCSessionDescription(
              message['sdp'],
              message['type'],
            ),
          );
        } else if (message['type'] == 'candidate') {
          final candidate = message['candidate'];

          await peerConnection.addCandidate(
            RTCIceCandidate(
              candidate['candidate'],
              candidate['sdpMid'],
              candidate['sdpMLineIndex'],
            ),
          );
        }
      },
      onError: (error) {
        if (isClosed() || !isMounted()) return;
        onSocketError('WebSocket error: $error');
      },
      onDone: () {
        if (isClosed() || !isMounted()) return;
        if (!hasRendererStream()) {
          onSocketDoneWithoutStream();
        }
      },
    );

    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);

    signalChannel.sink.add(
      jsonEncode({
        'type': offer.type,
        'sdp': offer.sdp,
      }),
    );

    return CameraFeedConnection(
      peerConnection: peerConnection,
      signalChannel: signalChannel,
    );
  }

  static Future<void> disconnect({
    required RTCVideoRenderer renderer,
    CameraFeedConnection? connection,
  }) async {
    final stream = renderer.srcObject;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
    }

    connection?.talkbackTrack?.stop();
    await connection?.localAudioStream?.dispose();

    renderer.srcObject = null;
    connection?.signalChannel.sink.close();
    await connection?.peerConnection.close();
  }
}
