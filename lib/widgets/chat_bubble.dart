import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    final msg = widget.message;
    final type = msg['type'] ?? 'text';

    if (type == 'image') {
      return ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(msg['message'], width: 220, fit: BoxFit.cover));
    } else if (type == 'doc') {
      return InkWell(
        onTap: () async {
          final uri = Uri.parse(msg['message']);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.picture_as_pdf, color: Colors.red),
            SizedBox(width: 8),
            Text('Open document', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );
    } else if (type == 'audio') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle, size: 28),
            onPressed: () async {
              final url = widget.message['message'];
              if (!_playing) {
                await _player.play(UrlSource(url));
                setState(() => _playing = true);
                _player.onPlayerComplete.listen((_) => setState(() => _playing = false));
              } else {
                await _player.pause();
                setState(() => _playing = false);
              }
            },
          ),
          Text('Voice', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      );
    } else {
      return Text(widget.message['message'] ?? '', style: const TextStyle(fontSize: 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final timestamp = msg['timestamp'] != null
        ? (msg['timestamp'] as Timestamp).toDate().toLocal()
        : DateTime.now();
    final timeStr = '${timestamp.hour.toString().padLeft(2,'0')}:${timestamp.minute.toString().padLeft(2,'0')}';

    final seen = widget.isMe ? (msg['seen'] ?? false) : false;

    final bubbleGradient = widget.isMe
        ? const LinearGradient(colors: [Color(0xff9ad6ff), Color(0xff77c6ff)])
        : const LinearGradient(colors: [Color(0xfff0f0f0), Color(0xffededed)]);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: widget.isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(gradient: bubbleGradient, borderRadius: radius, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0,1))]),
            child: _buildContent(),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              if (widget.isMe) ...[
                const SizedBox(width: 6),
                Icon(seen ? Icons.done_all : Icons.done, size: 14, color: seen ? Colors.blue : Colors.grey),
              ],
            ],
          )
        ],
      ),
    );
  }
}
