import 'package:flutter/material.dart';

class ExerciseRecommendationPage extends StatelessWidget {
  const ExerciseRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recommendations = [
      {
        'bmi_category': 'Overweight',
        'recommendation': '30 mins of moderate cardio daily (brisk walking, cycling)',
        'duration': 30
      },
      {
        'bmi_category': 'Normal',
        'recommendation': 'Maintain current activity: Mix of cardio and strength training',
        'duration': 45
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Recommendations', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('BMI Category: ${rec['bmi_category']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(rec['recommendation'], style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${rec['duration']} mins/day', style: const TextStyle(color: Colors.grey)),
                    ],
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
