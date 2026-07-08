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
    final historical = await CommunityService.getChatMessages(
      widget.community.id,
    );
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
        const SnackBar(
          content: Text('Koneksi terputus. Silakan coba sesaat lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDF9),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: widget.community.coverImageUrl.isNotEmpty
                    ? NetworkImage(widget.community.coverImageUrl)
                    : null,
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 18,
                onBackgroundImageError:
                    widget.community.coverImageUrl.isNotEmpty
                    ? (_, __) {}
                    : null,
                child: widget.community.coverImageUrl.isEmpty
                    ? const Icon(
                        Icons.diversity_3_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF81C784),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_onlineCount > 0 ? _onlineCount : 1} Online',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE8F5E9),
                        ),
                      ),
                    ],
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D631B),
                      ),
                    )
                  : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.forum_outlined,
                              size: 36,
                              color: Color(0xFF0D631B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Kirim pesan untuk memulai obrolan!',
                            style: TextStyle(
                              color: Color(0xFF6B8B72),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2EFE0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8F4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2EFE0)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1B3C21),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(
                            color: Color(0xFF6B8B72),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D631B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
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
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF0D631B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B8B72),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF0D631B) : Colors.white,
                    border: Border.all(
                      color: isMe
                          ? Colors.transparent
                          : const Color(0xFFE2EFE0),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: isMe
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isMe ? Colors.white : const Color(0xFF1B3C21),
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
              backgroundColor: const Color(0xFF0D631B),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
