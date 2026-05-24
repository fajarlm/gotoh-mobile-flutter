import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> communities = [
      {'name': 'Healthy Lifestyle', 'members': 120, 'description': 'Discuss daily healthy habits.'},
      {'name': 'Running Club', 'members': 85, 'description': 'Share your running routes and tips.'},
      {'name': 'Yoga Beginners', 'members': 45, 'description': 'A safe space to learn Yoga together.'}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final com = communities[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: const Icon(Icons.group),
              ),
              title: Text(com['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(com['description']),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  Text('${com['members']}'),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
