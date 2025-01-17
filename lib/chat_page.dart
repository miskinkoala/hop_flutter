import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/notifications.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _chats = [
    {
      'name': 'Alperen Özdelen',
      'lastMessage': 'Hey, how are you?',
      'tripInfo': 'Bayrampaşa → Gebze Teknik Üniversitesi',
      'avatar': 'images/logo.jpeg'
    },
    {
      'name': 'İsmail Kabak',
      'lastMessage': 'Are we still meeting tomorrow?',
      'tripInfo': 'Gebze Teknik Üniversitesi → Tubitak',
      'avatar': 'images/logo.jpeg'
    },
    {
      'name': 'Berk Hakan Öge',
      'lastMessage': 'Hello!.',
      'tripInfo': 'Gebze Teknik Üniversitesi → İzmit',
      'avatar': 'images/logo.jpeg'
    },
  ];

  final List<String> _messages = [
    "Hey there! How's everything?",
    "All good! How about you?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            automaticallyImplyLeading: false, // Removes the back button
            backgroundColor: Colors.green,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Color.fromARGB(255, 13, 95, 31)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
            toolbarHeight: 30,
            title: Text(
              "Chats",
              style: GoogleFonts.inriaSans(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color.fromARGB(255, 13, 95, 31),
                ),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: const Color.fromARGB(255, 224, 244, 229),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundImage: AssetImage(_chats[index]['avatar']!),
              radius: 28,
            ),
            title: Text(
              _chats[index]['name']!,
              style: GoogleFonts.inriaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chats[index]['tripInfo']!, // Trip info added here
                  style: GoogleFonts.inriaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                Text(
                  _chats[index]['lastMessage']!,
                  style: GoogleFonts.inriaSans(
                      fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black54),
            onTap: () => _openChatDetail(
              _chats[index]['name']!,
              _chats[index]['avatar']!,
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white,
          thickness: 1,
        ),
      ),
    );
  }

  void _openChatDetail(String name, String avatar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatDetailPage(name: name, messages: _messages, avatar: avatar),
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final String name;
  final List<String> messages;
  final String avatar;

  const ChatDetailPage({
    required this.name,
    required this.messages,
    required this.avatar,
    super.key,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _chatMessages.addAll(widget.messages);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add(_messageController.text.trim());
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.avatar),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(widget.name, style: GoogleFonts.inriaSans(fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: index % 2 == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? const Color.fromARGB(255, 171, 221, 173)
                          : const Color.fromARGB(255, 206, 234, 214),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _chatMessages[index],
                      style: GoogleFonts.inriaSans(
                          fontSize: 14, color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black26)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
