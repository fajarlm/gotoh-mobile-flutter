import 'package:flutter/material.dart';
import 'package:fe_mobile/model/community_model.dart';
import 'package:fe_mobile/model/user_model.dart';
import 'package:fe_mobile/services/community_service.dart';
import 'package:fe_mobile/services/auth_services.dart';
import 'package:fe_mobile/config/api_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomKomunitas extends StatefulWidget {
  final CommunityModel community;
  const ChatRoomKomunitas({super.key, required this.community});

  @override
  State<ChatRoomKomunitas> createState() => _ChatRoomKomunitasState();
}

class _ChatRoomKomunitasState extends State<ChatRoomKomunitas> {
  final List<ChatMessageModel> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  IO.Socket? _socket;
  bool _isLoading = true;
  int _currentUserId = 0;
  String _currentUsername = 'User';
  int _onlineCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndMessages();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('user_id') ?? 0;
    _currentUsername = prefs.getString('username') ?? 'User';

    // 1. Ambil data pesan historis via HTTP
    final historical = await CommunityService.getChatMessages(widget.community.id);
    setState(() {
      _messages.addAll(historical);
      _isLoading = false;
    });
    _scrollToBottom();

    // 2. Konek Socket.io
    _initSocket();
  }

  void _initSocket() {
    try {
      _socket = IO.io(
        ApiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('Socket connected to server');
        // Join room setelah koneksi berhasil
        _socket!.emit('join_room', {
          'groupId': widget.community.id,
          'username': _currentUsername,
        });
      });

      _socket!.on('online_users', (data) {
        if (data is List) {
          setState(() {
            _onlineCount = data.length;
          });
        }
      });

      _socket!.on('receive_message', (data) {
        if (data != null && data is Map<String, dynamic>) {
          final newMsg = ChatMessageModel.fromJson(data);
          // Hindari pesan duplikat jika ID-nya sama
          final exists = _messages.any((m) => m.id == newMsg.id);
          if (!exists) {
            setState(() {
              _messages.add(newMsg);
            });
            _scrollToBottom();
          }
        }
      });

      _socket!.onDisconnect((_) {
        print('Socket disconnected');
      });
    } catch (e) {
      print('Error initializing socket: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', {
        'userId': _currentUserId,
        'groupId': widget.community.id,
        'message': text,
      });
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koneksi terputus. Silakan coba sesaat lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D631B),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.community.coverImageUrl),
              backgroundColor: const Color(0xFFC9E7CA),
              radius: 18,
              onBackgroundImageError: (_, __) {
                // Fallback icon handled automatically by background widget structure
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.community.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_onlineCount > 0 ? _onlineCount : 1} Online',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC9E7CA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Message List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D631B)))
                  : _messages.isEmpty
                      ? const Center(
                          child: Text(
                            'Kirim pesan untuk memulai obrolan!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg.userId == _currentUserId;

                            return _buildMessageBubble(msg, isMe);
                          },
                        ),
            ),
            // Message Input Bar
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5EB),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE0E4DA)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D631B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    final name = msg.user?.username ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF0D631B),
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    name,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFC9E7CA) : Colors.white,
                    border: Border.all(color: const Color(0xFFE0E4DA)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF181D17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFC9E7CA),
              child: Text(
                initial,
                style: const TextStyle(color: Color(0xFF0D631B), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}