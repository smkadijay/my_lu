import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe, String? avatarUrl, required String messageType});

  bool _isImage(String? url) {
    if (url == null) return false;
    return url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png') || url.endsWith('.gif');
  }

  bool _isAudio(String? url) {
    if (url == null) return false;
    return url.endsWith('.mp3') || url.endsWith('.wav') || url.endsWith('.m4a') || url.endsWith('.aac');
  }

  bool _isFile(String? url) {
    if (url == null) return false;
    return url.endsWith('.pdf') || url.endsWith('.doc') || url.endsWith('.docx') || url.endsWith('.txt') || url.endsWith('.zip');
  }

  @override
  Widget build(BuildContext context) {
    // Accept both 'text' and legacy 'message' keys
    final text = (message['text'] ?? message['message'] ?? '') as String;
    final fileUrl = message['fileUrl'] as String?;
    String timeStr = '';
    if (message['timestamp'] != null) {
      try {
        final dt = (message['timestamp']).toDate();
        timeStr = DateFormat('hh:mm a').format(dt);
      } catch (_) {}
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // show message text
            if (text.isNotEmpty)
              Text(text, style: const TextStyle(fontSize: 15)),

            // show image, file or audio preview
            if (fileUrl != null && fileUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              if (_isImage(fileUrl))
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(fileUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fileUrl,
                      width: 200,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
              if (_isFile(fileUrl))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file, size: 28, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(child: Text('File: ${message['fileName'] ?? fileUrl.split('/').last}', overflow: TextOverflow.ellipsis)),
                  ],
                ),
              if (_isAudio(fileUrl))
                Row(children: const [Icon(Icons.audiotrack, color: Colors.black54), SizedBox(width: 8), Text('Audio File')]),

              // download and share buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download, size: 22),
                    onPressed: () async {
                      final uri = Uri.parse(fileUrl);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 22),
                    onPressed: () async {
                      await Share.share(fileUrl);
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: 4),
            if (timeStr.isNotEmpty)
              Text(timeStr, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }
}