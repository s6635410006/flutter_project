// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CustomerChatPage extends StatefulWidget {
  final String adminId;
  final String adminName;

  const CustomerChatPage({
    super.key,
    required this.adminId,
    required this.adminName,
  });

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  Future<void> _sendImage() async {
    final XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final path = 'chat/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from('chat_images').uploadBinary(path, bytes);

      final url = _supabase.storage.from('chat_images').getPublicUrl(path);

      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser!.id,
        'receiver_id': widget.adminId,
        'content': '',
        'image_url': url,
        'is_from_admin': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Upload Error: $e");
    }
  }

  // ✅ ส่งข้อความ
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser!.id,
        'receiver_id': widget.adminId,
        'content': text,
        'is_from_admin': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('ส่งข้อความไม่สำเร็จ: $e');
    }
  }

  // ✅ เลื่อนลงล่างสุด
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        title: Text(widget.adminName, style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 226, 206, 223),
        foregroundColor: Color.fromARGB(255, 190, 58, 113),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(), // ⭐ ใช้อันเดียว
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ✅ แสดงรายการข้อความ (ตัวเดียวพอ)
Widget _buildMessageList() {
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final myId = _supabase.auth.currentUser!.id;

      final msgs = snapshot.data!.where((m) {
        final s = m['sender_id'];
        final r = m['receiver_id'];

        return (s == myId && r == widget.adminId) ||
            (s == widget.adminId && r == myId);
      }).toList();

      // 🔥 ทำ scroll หลัง render เสร็จ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: msgs.length,
        itemBuilder: (context, index) {
          final msg = msgs[index];
          final isMe = msg['sender_id'] == myId;

          return _buildChatBubble(msg, isMe);
        },
      );
    },
  );
}
  // ✅ Bubble UI (เหมือนเดิม เพิ่มรองรับรูป + เวลา)
  Widget _buildChatBubble(Map<String, dynamic> msg, bool isMe) {
    final hasImage =
        msg['image_url'] != null && msg['image_url'].toString().isNotEmpty;

    final time = msg['created_at'] != null
        ? DateFormat('HH:mm')
            .format(DateTime.parse(msg['created_at']).toLocal())
        : '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 👤 ฝั่งแอดมิน
              if (!isMe)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFE6B0D6),
                    child: Icon(Icons.store, size: 18, color: Colors.white),
                  ),
                ),

              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Color.fromARGB(255, 231, 145, 206)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(isMe ? 15 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (hasImage)
                        Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(msg['image_url'],
                                fit: BoxFit.cover),
                          ),
                        ),
                      if ((msg['content'] ?? '').toString().isNotEmpty)
                        Text(
                          msg['content'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ⏰ เวลา
          Padding(
            padding: EdgeInsets.only(top: 2, left: 6, right: 6),
            child: Text(
              time,
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  // ------- ช่องพิมพ์ข้อความ -------
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            // 📸 ปุ่มส่งรูป
            IconButton(
              icon: Icon(Icons.image_outlined, color: Colors.pinkAccent),
              onPressed: _sendImage,
            ),

            // ------- ช่องพิมพ์ -----
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController, // ⭐ แก้
                  onSubmitted: (_) => _sendMessage(), // ⭐ แก้
                  decoration: InputDecoration(
                    hintText: "พิมพ์ข้อความที่นี่...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            SizedBox(width: 5),

            // ------- ปุ่มส่งข้อความ-----
            CircleAvatar(
              backgroundColor:
                  Color.fromARGB(255, 199, 99, 182), //สีปุ่มส่งจร้า
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (_messageController.text.trim().isEmpty) return;
                  _sendMessage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
