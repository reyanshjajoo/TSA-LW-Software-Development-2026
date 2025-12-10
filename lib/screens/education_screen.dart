import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("About the Deaf Community"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            _sectionTitle("Deaf Culture Overview"),
            _infoCard(
              icon: Icons.people_alt_rounded,
              title: "What Is the Deaf Community?",
              content:
                  "A cultural and linguistic community that uses American Sign Language (ASL) "
                  "and values visual communication, identity, and shared experience.",
            ),

            _infoCard(
              icon: Icons.language,
              title: "Importance of ASL",
              content:
                  "ASL is a complete, natural language with its own grammar and structure. "
                  "It is central to Deaf identity and communication.",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Communication in the Deaf Community"),
            _infoCard(
              icon: Icons.visibility,
              title: "Visual Communication",
              content:
                  "Communication relies on ASL, facial expressions, gestures, body language, "
                  "and other visual cues.",
            ),

            _infoCard(
              icon: Icons.textsms_rounded,
              title: "Other Communication Modes",
              content:
                  "• Lip reading (limited accuracy)\n"
                  "• Written communication\n"
                  "• Captioning tools\n"
                  "• Video Relay Services (VRS)",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Common Misconceptions"),
            _infoCard(
              icon: Icons.error_outline,
              title: "Myths vs Reality",
              content:
                  "• Deaf people cannot communicate — False.\n"
                  "• ASL is universal — False, each country has its own sign language.\n"
                  "• Hearing aids 'fix' hearing — They only assist, not restore.",
            ),

            const SizedBox(height: 20),

            _sectionTitle("How to Support the Deaf Community"),
            _infoCard(
              icon: Icons.volunteer_activism_rounded,
              title: "Ways to Help",
              content:
                  "• Learn basic ASL.\n"
                  "• Maintain eye contact and be patient.\n"
                  "• Ensure captions and interpreters are available.\n"
                  "• Respect Deaf culture and identity.",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Additional Resources"),
            _resourceCard(
              title: "ASL Learning Websites",
              links: [
                "StartASL.com",
                "ASL University (Lifeprint.com)",
                "Gallaudet University ASL Resources"
              ],
            ),

            _resourceCard(
              title: "Organizations Supporting the Deaf Community",
              links: [
                "National Association of the Deaf (NAD)",
                "American Society for Deaf Children",
                "DeafNation Expo",
              ],
            ),

            _resourceCard(
              title: "Technology and Accessibility Tools",
              links: [
                "Google Live Transcribe",
                "AV Interpreter Apps",
                "Closed Captioning Extensions",
              ],
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                "Thank you for learning and making the world more inclusive!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE WIDGET
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // GENERAL INFO CARD
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: Colors.blueGrey[700]),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // RESOURCE CARD LIST STYLE
  Widget _resourceCard({
    required String title,
    required List<String> links,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            for (var link in links)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        link,
                        style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
