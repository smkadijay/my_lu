import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ChatInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String receiverId;

  const ChatInput({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _text = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scroll = ScrollController();
  bool _busy = false;

  File? _img;
  File? _file;
  String? _fileName;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recInited = false;
  bool _isRecording = false;
  String? _audioPath;
  Timer? _recTimer;
  int _recSec = 0;

  final String cloudName = 'daaz6phgh';
  final String preset = 'unsigned_upload';
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _markSeen();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder.openRecorder();
    _recInited = true;
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _recTimer?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  // Cloudinary upload
  Future<String?> _upload(File f, String type) async {
    setState(() => _busy = true);
    try {
      final url = type == 'image'
          ? 'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
          : 'https://api.cloudinary.com/v1_1/$cloudName/raw/upload';
      final req = http.MultipartRequest('POST', Uri.parse(url));
      req.fields['upload_preset'] = preset;
      req.files.add(await http.MultipartFile.fromPath('file', f.path, filename: p.basename(f.path)));
      final res = await req.send();
      final body = await res.stream.bytesToString();
      if (res.statusCode == 200) return jsonDecode(body)['secure_url'];
    } catch (e) {
      debugPrint('upload error: $e');
    } finally {
      setState(() => _busy = false);
    }
    return null;
  }

  Future<void> _markSeen() async {
    final msgRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');
    final unread = await msgRef
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('seen', isEqualTo: false)
        .get();
    for (var doc in unread.docs) {
      doc.reference.update({'seen': true});
    }
  }

  Future<void> _sendMessage(Map<String, dynamic> msg) async {
    final ref = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');
    await ref.add(msg);
    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': msg['type'] == 'text'
          ? msg['text']
          : msg['type'] == 'image'
              ? '📷 Photo'
              : msg['type'] == 'audio'
                  ? '🎧 Audio'
                  : '📎 File',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSender': widget.currentUserId,
      'unreadCounts.${widget.receiverId}': FieldValue.increment(1),
    });
  }

  Future<void> _sendText() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    await _sendMessage({
      'senderId': widget.currentUserId,
      'receiverId': widget.receiverId,
      'text': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
    });
    _text.clear();
  }

  Future<void> _sendImage() async {
    if (_img == null) return;
    final url = await _upload(_img!, 'image');
    if (url != null) {
      await _sendMessage({
        'senderId': widget.currentUserId,
        'receiverId': widget.receiverId,
        'fileUrl': url,
        'type': 'image',
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });
    }
    setState(() => _img = null);
  }

  Future<void> _sendFile() async {
    if (_file == null) return;
    final url = await _upload(_file!, 'raw');
    if (url != null) {
      await _sendMessage({
        'senderId': widget.currentUserId,
        'receiverId': widget.receiverId,
        'fileUrl': url,
        'fileName': _fileName ?? '',
        'type': 'doc',
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });
    }
    setState(() => _file = null);
  }


  Future<void> _startRec() async {
    if (!_recInited) await _initRecorder();
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) return;
    final temp = Directory.systemTemp;
    _audioPath = '${temp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: _audioPath);
    setState(() {
      _isRecording = true;
      _recSec = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recSec++);
    });
  }

  Future<void> _stopRec() async {
    await _recorder.stopRecorder();
    _recTimer?.cancel();
    setState(() => _isRecording = false);
  }

  Future<void> _sendAudio() async {
    if (_audioPath == null) return;
    final file = File(_audioPath!);
    final url = await _upload(file, 'raw');
    if (url != null) {
      await _sendMessage({
        'senderId': widget.currentUserId,
        'receiverId': widget.receiverId,
        'fileUrl': url,
        'type': 'audio',
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
      });
    }
    setState(() {
      _audioPath = null;
      _recSec = 0;
    });
  }

  void _typing(bool active) {
    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).set({
      'typing': {widget.currentUserId: active}
    }, SetOptions(merge: true));

    _typingTimer?.cancel();
    if (active) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId).set({
          'typing': {widget.currentUserId: false}
        }, SetOptions(merge: true));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const topGradient = LinearGradient(
      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: const BoxDecoration(gradient: topGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF01579B), Color(0xFF0288D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.receiverId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('Chat', style: TextStyle(color: Colors.white));
                  }
                  final user = snapshot.data!;
                  final name = user['name'] ?? 'Unknown';
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chatId)
                        .snapshots(),
                    builder: (context, snap) {
                      final typing = (snap.data?['typing'] ?? {}) as Map<String, dynamic>;
                      final isTyping = typing[widget.receiverId] ?? false;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(isTyping ? 'Typing...' : 'Online',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Message list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  final msgs = snapshot.data!.docs;
                  return ListView.builder(
                    controller: _scroll,
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final m = msgs[i].data() as Map<String, dynamic>;
                      final isMe = m['senderId'] == widget.currentUserId;
                      final seen = m['seen'] == true;
                      final ts = (m['timestamp'] as Timestamp?)?.toDate();
                      final time = ts != null
                          ? DateFormat('hh:mm a').format(ts)
                          : '';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.teal.shade600
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (m['type'] == 'text')
                                Text(m['text'] ?? '',
                                    style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black87)),
                              if (m['type'] == 'image')
                                GestureDetector(
                                  onTap: () => launchUrl(Uri.parse(m['fileUrl'])),
                                  child: Image.network(m['fileUrl'],
                                      width: 200, height: 140, fit: BoxFit.cover),
                                ),
                              if (m['type'] == 'doc')
                                Row(
                                  children: [
                                    const Icon(Icons.insert_drive_file,
                                        color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Text(m['fileName'] ?? 'File',
                                            style: const TextStyle(color: Colors.black))),
                                    IconButton(
                                        icon: const Icon(Icons.open_in_new),
                                        onPressed: () => launchUrl(Uri.parse(m['fileUrl']))),
                                  ],
                                ),
                              if (m['type'] == 'audio')
                                Row(
                                  children: const [
                                    Icon(Icons.mic, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text("Voice message",
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(time,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: isMe
                                              ? Colors.white70
                                              : Colors.black54)),
                                  if (isMe)
                                    Icon(seen ? Icons.done_all : Icons.check,
                                        size: 14,
                                        color:
                                            seen ? Colors.blue : Colors.white70),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Footer (input bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.image, color: Colors.deepPurpleAccent),
                      onPressed: () async {
                        final x = await _picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 75);
                        if (x != null) setState(() => _img = File(x.path));
                      }),
                  IconButton(
                      icon: const Icon(Icons.attach_file,
                          color: Colors.orangeAccent),
                      onPressed: () async {
                        final f = await FilePicker.platform.pickFiles();
                        if (f != null && f.files.isNotEmpty) {
                          setState(() {
                            _file = File(f.files.single.path!);
                            _fileName = f.files.single.name;
                          });
                        }
                      }),
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                        color: _isRecording ? Colors.red : Colors.redAccent),
                    onPressed: () async {
                      if (_isRecording) {
                        await _stopRec();
                        await _sendAudio();
                      } else {
                        await _startRec();
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      onChanged: (v) => _typing(v.trim().isNotEmpty),
                      decoration: const InputDecoration(
                          hintText: 'Type message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white)),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  _busy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon:
                              const Icon(Icons.send, color: Colors.deepPurpleAccent),
                          onPressed: () async {
                            if (_img != null) await _sendImage();
                            else if (_file != null) await _sendFile();
                            else await _sendText();
                          }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
