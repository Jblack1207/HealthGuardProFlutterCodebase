import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Helpers/CameraFeedHelper.dart';

import 'IoTHealthAppFaceUploadPage.dart';


class IoTHealthAppCamPageViewer extends StatefulWidget {
  final String deviceId;

  const IoTHealthAppCamPageViewer({
    super.key,
    required this.deviceId,
  });

  @override
  State<IoTHealthAppCamPageViewer> createState() =>
      _IoTHealthAppCamPageViewerState();
}

class _IoTHealthAppCamPageViewerState
    extends State<IoTHealthAppCamPageViewer> {
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  CameraFeedConnection? _connection;

  bool _isConnecting = true;
  String? _error;
  bool _closed = false;

  bool _isMuted = false;
  MediaStream? _remoteStream;
  bool _isMicMuted = true;


  late final String _viewKey;

  @override
  void initState() {
    super.initState();
    _viewKey = DateTime.now().microsecondsSinceEpoch.toString();
    _startConnection();

  }

  Future<void> _toggleMicMute() async {
    final nextMicMuted = !_isMicMuted;

    if (!nextMicMuted) {
      await _connection?.ensureTalkbackTrack();
    }

    await _connection?.setTalkbackEnabled(!nextMicMuted);

    _connection?.signalChannel.sink.add(
      jsonEncode({
        'type': 'talkback',
        'enabled': !nextMicMuted,
      }),
    );

    if (!mounted) return;

    setState(() {
      _isMicMuted = nextMicMuted;
    });
  }

  Future<void> _startConnection() async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      await _remoteRenderer.initialize();

      _connection = await CameraFeedService.connect(
        deviceId: widget.deviceId,
        isClosed: () => _closed,
        isMounted: () => mounted,
        hasRendererStream: () => _remoteRenderer.srcObject != null,
        onTrackDebug: debugPrint,
        onAnswerReceived: debugPrint,
        onAudioTrack: () {
          debugPrint('Remote audio track received');
        },
        onVideoStream: (stream) async {
          _remoteStream = stream;

          if (_remoteRenderer.srcObject != null) {
            _remoteRenderer.srcObject = null;
            await Future.delayed(const Duration(milliseconds: 100));
          }

          if (!mounted || _closed) return;

          setState(() {
            _remoteRenderer.srcObject = stream;
          });

          debugPrint('Renderer stream assigned');

          await Future.delayed(const Duration(milliseconds: 50));

          if (!mounted || _closed) return;

          setState(() {
            _remoteRenderer.srcObject = stream;
          });

          _applyMuteState();
        },
        onSocketError: (error) {
          setState(() {
            _error = error;
            _isConnecting = false;
          });
        },
        onSocketDoneWithoutStream: () {
          setState(() {
            _error = 'No active camera feed for this device';
            _isConnecting = false;
          });
        },
      );

      if (!mounted || _closed) return;

      setState(() {
        _isConnecting = false;
      });
    } catch (e) {
      if (!mounted || _closed) return;

      setState(() {
        _error = 'Failed to start camera feed: $e';
        _isConnecting = false;
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    _applyMuteState();
  }

  void _applyMuteState() {
    final stream = _remoteStream;
    if (stream == null) return;

    for (final track in stream.getAudioTracks()) {
      track.enabled = !_isMuted;
    }
  }



  @override
  void dispose() {
    _closed = true;
    _remoteStream = null;
    CameraFeedService.disconnect(
      renderer: _remoteRenderer,
      connection: _connection,
    );
    _remoteRenderer.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (_isConnecting) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 14,
          ),
        ),
      );
    }

    if (_remoteRenderer.srcObject == null) {
      return const Center(
        child: Text(
          'Waiting for video...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 260,
        child: RTCVideoView(
          _remoteRenderer,
          key: ValueKey('camera-${widget.deviceId}-$_viewKey'),
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xff1F1F1F),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/HGLongLogo.svg',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Transform.translate(
                      offset: const Offset(-20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Text(
                            'Live Camera Feed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Device ID: ${widget.deviceId}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xaa27272A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xaa27272A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleMicMute,
                        icon: Icon(
                          _isMicMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IoTHealthAppFaceUploadPage(
                                deviceId: widget.deviceId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          //TODO add fullscreen capabilities
                        },
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
