import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    Widget content;
    final timestamp = message["timestamp"] != null
        ? DateFormat('hh:mm a').format(message["timestamp"].toDate())
        : "";

    switch (message["type"]) {
      case "text":
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message["text"], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(timestamp, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        );
        break;

      case "image":
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(message["url"], width: 200, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 4),
            Text(timestamp, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        );
        break;

      case "document":
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(message["url"]);
                if (await canLaunchUrl(url)) await launchUrl(url);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(message["name"], overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.download, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(timestamp, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        );
        break;

      case "voice":
        content = VoiceMessageWidget(url: message["url"], timestamp: timestamp);
        break;

      default:
        content = const Text("Unsupported message");
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent])
              : const LinearGradient(colors: [Colors.grey, Color.fromARGB(255, 195, 192, 192)]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

class VoiceMessageWidget extends StatefulWidget {
  final String url;
  final String timestamp;

  const VoiceMessageWidget({super.key, required this.url, required this.timestamp});

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  void togglePlay() async {
    if (isPlaying) {
      await _player.stop();
      setState(() => isPlaying = false);
    } else {
      await _player.play(UrlSource(widget.url));
      setState(() => isPlaying = true);
      _player.onPlayerComplete.listen((event) => setState(() => isPlaying = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.purple),
          onPressed: togglePlay,
        ),
        Text("Voice Message", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(widget.timestamp, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}
