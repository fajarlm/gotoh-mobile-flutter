import 'package:flutter/material.dart';

class MedicalCheckupPage extends StatelessWidget {
  const MedicalCheckupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Static data representing medical checkup history
    final List<Map<String, dynamic>> checkups = [
      {
        'date': '24 May 2026',
        'blood_pressure': '120/80',
        'heart_rate': 72,
        'blood_sugar': 95.0,
        'cholesterol': 180.0,
        'weight': 70.5,
        'height': 175.0,
        'notes': 'All vital signs are normal. Keep up the good work.'
      },
      {
        'date': '10 Apr 2026',
        'blood_pressure': '118/79',
        'heart_rate': 75,
        'blood_sugar': 100.0,
        'cholesterol': 190.0,
        'weight': 71.0,
        'height': 175.0,
        'notes': 'Slightly elevated blood sugar, recommended less sugar intake.'
      }
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Medical Checkup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Checkups',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...checkups.map((checkup) => _buildCheckupCard(context, checkup)).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add new checkup
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCheckupCard(BuildContext context, Map<String, dynamic> checkup) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      checkup['date'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              children: [
                _buildStatItem(Icons.favorite, 'Heart', '${checkup['heart_rate']} bpm', Colors.redAccent),
                _buildStatItem(Icons.bloodtype, 'BP', '${checkup['blood_pressure']}', Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(Icons.water_drop, 'Sugar', '${checkup['blood_sugar']} mg/dL', Colors.lightBlue),
                _buildStatItem(Icons.monitor_weight, 'Weight', '${checkup['weight']} kg', Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checkup['notes'],
                      style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
