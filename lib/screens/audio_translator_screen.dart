import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

/// A screen that allows the user to transcribe audio into text using Assembly AI.
///
/// This screen uses the Assembly AI streaming API to transcribe audio in real-time.
/// The user can start and stop the transcription, and the recognized text is
/// displayed on the screen.
class AudioTranslatorScreen extends StatefulWidget {
  const AudioTranslatorScreen({super.key});

  @override
  State<AudioTranslatorScreen> createState() => _AudioTranslatorScreenState();
}

/// The state of the [AudioTranslatorScreen].
///
/// This class manages the state of the screen, including whether the transcription
/// is currently in progress and the recognized text.
class _AudioTranslatorScreenState extends State<AudioTranslatorScreen> {
  bool isListening = false;
  String recognizedText = "";
  final _recorder = AudioRecorder();
  WebSocketChannel? _ws;
  StreamSubscription<Uint8List>? _micSub;

  final List<int> _pendingBytes = [];
  final StringBuffer _text = StringBuffer();

  bool _wsConnected = false;
  int _turnIndex = 1;

  static const int _sampleRate = 16000;
  // 50 ms frame at 16kHz, 16-bit mono
  static const int _bytesPer50ms = (_sampleRate * 2 * 50 ~/ 1000);

  /// Fetches a streaming token from the Assembly AI server.
  ///
  /// Throws an exception if the token fetch fails.
  Future<String> _getStreamingToken() async {
    final resp = await http.get(Uri.parse('https://streaming.assemblyai.com/v3/token?expires_in_seconds=60'),
        headers: {'authorization': 'ab116549006d4c568a77295d98d0c9d1'});
    if (resp.statusCode != 200) {
      throw Exception('Token fetch failed: ${resp.statusCode}\n${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['token'] as String;
  }

  /// Starts the transcription process.
  ///
  /// Connects to the Assembly AI streaming API and starts streaming audio from the
  /// microphone. The recognized text is displayed on the screen.
  Future<void> startListening() async {
    if (isListening) return;
    setState(() {
      isListening = true;
      recognizedText = 'Connecting...';
    });

    // Mic permission
    if (!await _recorder.hasPermission()) {
      setState(() {
        isListening = false;
        recognizedText = 'Microphone permission denied.';
      });
      return;
    }

    try {
      final token = await _getStreamingToken();
      final uri = Uri.parse(
        'wss://streaming.assemblyai.com/v3/ws?sample_rate=$_sampleRate&encoding=pcm_s16le&token=$token',
      );

      _ws = WebSocketChannel.connect(uri);
      _wsConnected = true;

      // Receive events
      _ws!.stream.listen((event) {
        try {
          if (event is String) {
            final msg = jsonDecode(event) as Map<String, dynamic>;
            switch (msg['type']) {
              case 'Begin':
                setState(() => recognizedText = 'Listening...');
                break;
              case 'Turn':
                final transcript = (msg['transcript'] ?? '') as String;
                final endOfTurn = (msg['end_of_turn'] ?? false) as bool;
                if (transcript.isNotEmpty) {
                  // Optional pseudo-label per turn (not true diarization)
                  if (endOfTurn) {
                    _text.writeln('Turn $_turnIndex: $transcript');
                    _turnIndex++;
                  } else {
                    _text.write(transcript);
                  }
                  setState(() => recognizedText = _text.toString());
                }
                break;
              case 'Termination':
                break;
            }
          }
        } catch (_) {
          // ignore malformed messages
        }
      }, onDone: () {
        _wsConnected = false;
        if (isListening) stopListening();
      }, onError: (e) {
        _wsConnected = false;
        setState(() => recognizedText = 'Connection error: $e');
      });

      // Optional: tweak endpointing and formatting
      _ws!.sink.add(jsonEncode({
        'type': 'UpdateConfiguration',
        'format_turns': true,
        'end_of_turn_confidence_threshold': 0.5,
      }));

      // Start mic stream as raw PCM 16kHz mono
      final stream = await _recorder.startStream(RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        noiseSuppress: true,
        echoCancel: true,
      ));

      _micSub = stream.listen((chunk) {
        if (!_wsConnected) return;
        _pendingBytes.addAll(chunk);
        // Send ~50ms frames
        while (_pendingBytes.length >= _bytesPer50ms) {
          final frame = Uint8List.fromList(_pendingBytes.sublist(0, _bytesPer50ms));
          _ws?.sink.add(frame); // binary frame
          _pendingBytes.removeRange(0, _bytesPer50ms);
        }
      });
    } catch (e) {
      setState(() {
        isListening = false;
        recognizedText = 'Start failed: $e';
      });
      await _cleanup();
    }
  }

  /// Stops the transcription process.
  ///
  /// Sends a termination message to the Assembly AI streaming API and cancels the
  /// microphone subscription.
  Future<void> stopListening() async {
    if (!isListening) return;
    setState(() => isListening = false);
    try {
      if (_wsConnected) {
        _ws?.sink.add(jsonEncode({'type': 'ForceEndpoint'}));
        _ws?.sink.add(jsonEncode({'type': 'Terminate'}));
      }
    } catch (_) {}
    await _cleanup();
  }

  /// Cleans up the transcription process.
  ///
  /// Cancels the microphone subscription and closes the WebSocket connection.
  Future<void> _cleanup() async {
    try {
      await _micSub?.cancel();
    } catch (_) {}
    _micSub = null;

    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}

    try {
      await _ws?.sink.close();
    } catch (_) {}
    _ws = null;
    _wsConnected = false;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 122, 217, 168),
      appBar: AppBar(
        title: const Text("Audio to Text"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 60, 120, 88),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Speech Input",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Microphone bubble
                GestureDetector(
                  onTap: () => isListening ? stopListening() : startListening(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isListening ? 160 : 140,
                    width: isListening ? 160 : 140,
                    decoration: BoxDecoration(
                      color:
                          isListening ? const Color.fromARGB(255, 9, 173, 31) : Colors.blueGrey[200],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isListening
                              ? const Color.fromARGB(255, 5, 68, 18)
                              : Colors.black12,
                          blurRadius: isListening ? 25 : 10,
                          spreadRadius: isListening ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Start/Stop Listening button
                ElevatedButton(
                  onPressed: () => isListening ? stopListening() : startListening(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(isListening ? "Stop Listening" : "Start Listening"),
                ),

                const SizedBox(height: 20),

                // Recognized text output
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 60, 120, 88),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        recognizedText.isEmpty
                            ? "Tap the microphone to begin."
                            : recognizedText,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
