import 'package:flutter/material.dart';
import 'package:fe_mobile/views/auth_page.dart';
import 'package:fe_mobile/views/community_page.dart';
import 'package:fe_mobile/views/post_page.dart';
import 'package:fe_mobile/views/chat_page.dart';
import 'package:fe_mobile/views/exercise_recommendation_page.dart';
import 'package:fe_mobile/views/medical_checkup_page.dart';
import 'package:fe_mobile/views/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'title': 'Auth (Login)', 'icon': Icons.login, 'page': const AuthPage(), 'color': Colors.indigo},
      {'title': 'Community', 'icon': Icons.group, 'page': const CommunityPage(), 'color': Colors.green},
      {'title': 'Feed', 'icon': Icons.dynamic_feed, 'page': const PostPage(), 'color': Colors.orange},
      {'title': 'Chat', 'icon': Icons.chat, 'page': const ChatPage(), 'color': Colors.blue},
      {'title': 'Exercise Rec', 'icon': Icons.fitness_center, 'page': const ExerciseRecommendationPage(), 'color': Colors.purple},
      {'title': 'Med Checkup', 'icon': Icons.monitor_heart, 'page': const MedicalCheckupPage(), 'color': Colors.red},
      {'title': 'Profile', 'icon': Icons.person, 'page': const ProfilePage(), 'color': Colors.teal},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoToh Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => feature['page']),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature['icon'],
                      size: 40,
                      color: feature['color'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
