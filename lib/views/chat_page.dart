import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {'name': 'Dr. Sarah', 'msg': 'Your test results look good.', 'time': '10:30 AM', 'unread': 1},
      {'name': 'Healthy Lifestyle Group', 'msg': 'Jane: Let\'s do morning yoga!', 'time': 'Yesterday', 'unread': 0},
      {'name': 'John Smith', 'msg': 'Thanks for the tip!', 'time': 'Monday', 'unread': 0}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person),
            ),
            title: Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat['msg'], maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                if (chat['unread'] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${chat['unread']}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  )
              ],
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
