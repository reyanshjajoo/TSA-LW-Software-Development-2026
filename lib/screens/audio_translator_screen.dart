import 'package:flutter/material.dart';

class AudioTranslatorScreen extends StatefulWidget {
  const AudioTranslatorScreen({super.key});

  @override
  State<AudioTranslatorScreen> createState() => _AudioTranslatorScreenState();
}

class _AudioTranslatorScreenState extends State<AudioTranslatorScreen> {
  bool isListening = false;
  String recognizedText = "";
  String aslOutput = "";

  // TODO: integrate real speech recognition
  void toggleListening() {
    setState(() {
      isListening = !isListening;

      if (isListening) {
        recognizedText = "Listening...";
      } else {
        recognizedText = "Tap microphone to start listening.";
      }
    });
  }

  // Converts each A–Z letter into an ASL placeholder (later: images)
  void convertToASL(String text) {
    String clean = text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), "");
    setState(() {
      aslOutput = clean.split("").join(" ");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Audio → ASL Translator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // LEFT PANEL: AUDIO + TEXT
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Microphone circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isListening ? 160 : 140,
                      width: isListening ? 160 : 140,
                      decoration: BoxDecoration(
                        color: isListening ? Colors.red[300] : Colors.blueGrey[200],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isListening ? Colors.redAccent : Colors.black12,
                            blurRadius: isListening ? 20 : 8,
                            spreadRadius: isListening ? 3 : 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Listen button
                    ElevatedButton(
                      onPressed: () {
                        toggleListening();
                        convertToASL(recognizedText); // temporary
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(isListening ? "Stop Listening" : "Start Listening"),
                    ),

                    const SizedBox(height: 20),

                    // Recognized text
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          recognizedText,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // RIGHT PANEL: ASL OUTPUT
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ASL Output",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          aslOutput.isEmpty
                              ? "Speak something to convert to ASL!"
                              : aslOutput,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
