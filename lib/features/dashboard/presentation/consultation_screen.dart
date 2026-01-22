import 'dart:ui';
import 'package:flutter/material.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Consult a Nutritionist"),
      ),
      body: Stack(
        children: [
          // -------- BACKGROUND --------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF1A2A32),
                ],
              ),
            ),
          ),

          // Soft glow
          Positioned(
            top: -120,
            right: -120,
            child: _MistGlow(color: Colors.greenAccent),
          ),

          // -------- CONTENT --------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Get expert guidance",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Certified nutritionists, personalised for you",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 28),

                  Expanded(
                    child: ListView(
                      children: const [
                        _DoctorCard(
                          name: "Dr. Ananya Rao",
                          speciality: "Weight Loss Specialist",
                          experience: "8 yrs experience",
                          rating: 4.8,
                        ),
                        _DoctorCard(
                          name: "Dr. Rahul Mehta",
                          speciality: "Sports Nutritionist",
                          experience: "10 yrs experience",
                          rating: 4.6,
                        ),
                        _DoctorCard(
                          name: "Dr. Priya Sharma",
                          speciality: "Diabetes & Diet Care",
                          experience: "7 yrs experience",
                          rating: 4.9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DOCTOR CARD
// ============================================================

class _DoctorCard extends StatelessWidget {
  final String name;
  final String speciality;
  final String experience;
  final double rating;

  const _DoctorCard({
    required this.name,
    required this.speciality,
    required this.experience,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF81C784),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        speciality,
                        style:
                            const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        experience,
                        style:
                            const TextStyle(color: Colors.white38),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                                color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // CTA
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Consult"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MIST GLOW
// ============================================================

class _MistGlow extends StatelessWidget {
  final Color color;

  const _MistGlow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 420,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.18),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
