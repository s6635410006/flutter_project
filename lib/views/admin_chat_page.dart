//-------หน้าแชทแอดมินคุยกับลูกค้า-------
// ignore_for_file: deprecated_member_use, unused_local_variable
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AdminChatPage extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String? customerAvatarUrl;

  const AdminChatPage({
    super.key,
    required this.customerId,
    required this.customerName,
    this.customerAvatarUrl, // ⭐ ต้องอยู่ตรงนี้
  });

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _msgController = TextEditingController();
  bool _isUploading = false;
  final ScrollController _scrollController = ScrollController();

  // ----------- ส่งรูปภาพ -----------
  Future<void> _sendImage() async {
    final XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      final path = 'chat/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('chat_images').uploadBinary(path, bytes);

      final url = supabase.storage.from('chat_images').getPublicUrl(path);

      final myId = supabase.auth.currentUser!.id;
      final otherUserId = widget.customerId;

      final res = await supabase.from('messages').insert({
        'sender_id': myId,
        'receiver_id': otherUserId,
        'content': 'ส่งรูปภาพ',
        'image_url': url,
        'is_from_admin': true,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select();
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ---------ส่งข้อความตัวอักษร ----------
  Future<void> _sendText({String? custom}) async {
    final txt = custom ?? _msgController.text.trim();
    if (txt.isEmpty) return;
    await supabase.from('messages').insert({
      'sender_id': supabase.auth.currentUser!.id,
      'receiver_id': widget.customerId,
      'created_at': DateTime.now().toIso8601String(),
      'content': txt,
      'is_from_admin': true,
      'is_read': false,
    });
    _msgController.clear();
  }

  Future<void> _markCustomerMessagesRead() async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) return;

      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', widget.customerId)
          .eq('receiver_id', myId)
          .eq('is_from_admin', false);
    } catch (_) {
      // ignore: best-effort
    }
  }

  @override
  void initState() {
    super.initState();
    _markCustomerMessagesRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customerName,
          style: TextStyle(
            color: Color(0xFFBE3A71), 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true, 
        backgroundColor:
            Color(0xFFE2CEDF), 
        foregroundColor: Color(0xFF6D4C41),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            if (_isUploading) LinearProgressIndicator(color: Colors.pinkAccent),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

//----------- แสดงรายการข้อความ -----------
  Widget _buildMessageList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('messages')
          .stream(primaryKey: ['id']).order('created_at', ascending: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // best-effort: mark incoming messages as read while viewing chat
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _markCustomerMessagesRead();
        });

        final myId = supabase.auth.currentUser!.id;
        final customerId = widget.customerId;

        final msgs = snapshot.data!.where((m) {
          final s = m['sender_id'];
          final r = m['receiver_id'];

          return (s == myId && r == customerId) ||
              (s == customerId && r == myId);
        }).toList();

        // 🔥 auto scroll เหมือนฝั่งลูกค้า
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

            return _buildMessageBubble(
              message: msg,
              isMe: isMe,
            );
          },
        );
      },
    );
  }

// 🚩 Widget ฟองคำพูด (Bubble)
  Widget _buildMessageBubble({
    required Map<String, dynamic> message,
    required bool isMe,
  }) {
    // ⏰ ต้องประกาศตรงนี้ (ก่อน return)
    final time = message['created_at'] != null
        ? DateFormat('HH:mm').format(
            DateTime.parse(message['created_at']).toLocal(),
          )
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 👤 avatar (ฝั่งซ้าย)
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF5E1F0),
                backgroundImage: (widget.customerAvatarUrl != null &&
                        widget.customerAvatarUrl!.isNotEmpty)
                    ? NetworkImage(widget.customerAvatarUrl!)
                    : null,
                child: (widget.customerAvatarUrl == null ||
                        widget.customerAvatarUrl!.isEmpty)
                    ? const Icon(Icons.person,
                        size: 18, color: Color(0xFF6D4C41))
                    : null,
              ),
            ),

          // 💬 bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color.fromARGB(255, 231, 145, 206)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // 🖼 image
                      if (message['image_url'] != null &&
                          message['image_url'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(message['image_url']),
                          ),
                        ),

                      // 💬 text
                      if ((message['content'] ?? '').toString().isNotEmpty)
                        Text(
                          message['content'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                ),

                // ⏰ เวลา (อยู่นอก bubble)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.image_outlined, color: Colors.pinkAccent),
              onPressed: _sendImage,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _msgController,
                  onSubmitted: (_) => _sendText(),
                  decoration: InputDecoration(
                    hintText: "พิมพ์ข้อความที่นี่...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 5),
            CircleAvatar(
              backgroundColor:
                  Color.fromARGB(255, 199, 99, 182), //สีปุ่มส่งจร้า
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (_msgController.text.trim().isEmpty) return;
                  _sendText();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
