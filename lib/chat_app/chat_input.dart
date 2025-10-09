import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Selection holders
  File? _selectedImage;
  File? _selectedFile; // doc or other
  String? _selectedFileName;

  // Recording
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderInited = false;
  bool _isRecording = false;
  String? _audioPath;
  Timer? _recTimer;
  int _recSeconds = 0;

  bool _busy = false; // while uploading

  final String cloudName = 'daaz6phgh'; // your cloud name
  final String preset = 'unsigned_upload'; // your unsigned preset

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder.openRecorder();
    _recorderInited = true;
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<String?> _uploadFileToCloudinary(File file, String type) async {
    setState(() => _busy = true);
    try {
      final endpoint = type == 'image'
          ? 'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
          : (type == 'raw' ? 'https://api.cloudinary.com/v1_1/$cloudName/raw/upload' : 'https://api.cloudinary.com/v1_1/$cloudName/video/upload');

      final uri = Uri.parse(endpoint);
      final req = http.MultipartRequest('POST', uri);
      req.fields['upload_preset'] = preset;
      req.files.add(await http.MultipartFile.fromPath('file', file.path, filename: p.basename(file.path)));

      final res = await req.send();
      final body = await res.stream.bytesToString();
      if (res.statusCode == 200) {
        final json = jsonDecode(body);
        return json['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary upload failed ${res.statusCode} $body');
        return null;
      }
    } catch (e) {
      debugPrint('upload error: $e');
      return null;
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  Future<void> _pickDocument() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.any);
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;
    setState(() {
      _selectedFile = File(path);
      _selectedFileName = res.files.single.name;
      _selectedImage = null;
    });
  }

  // recording handlers
  void _startRecording() async {
    if (!_recorderInited) return;
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) return;
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
    final tempPath = '/${fileName}';
    // use app temp directory
    final dir = Directory.systemTemp;
    _audioPath = '${dir.path}/$fileName';
    await _recorder.startRecorder(toFile: _audioPath, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
      _recSeconds = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    await _recorder.stopRecorder();
    _recTimer?.cancel();
    setState(() {
      _isRecording = false;
    });
    // audio file available at _audioPath
  }

  void _deleteRecording() {
    if (_audioPath != null) {
      try {
        final f = File(_audioPath!);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    setState(() {
      _audioPath = null;
      _recSeconds = 0;
      _isRecording = false;
    });
  }
  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': widget.currentUserId,
      'receiverId': widget.receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
      'type': 'text', // এইটা খুব গুরুত্বপূর্ণ
    });
  }


  Future<void> _sendMessageToFirestore(String content, String type) async {
    final messagesRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages');
    await messagesRef.add({
      'senderId': widget.currentUserId,
      'receiverId': widget.receiverId,
      'message': content,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
    });
  }

  Future<void> _sendSelectedImage() async {
    if (_selectedImage == null) return;
    final url = await _uploadFileToCloudinary(_selectedImage!, 'image');
    if (url != null) {
      await _sendMessageToFirestore(url, 'image');
      setState(() => _selectedImage = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed')));
    }
  }

  Future<void> _sendSelectedFile() async {
    if (_selectedFile == null) return;
    final url = await _uploadFileToCloudinary(_selectedFile!, 'raw');
    if (url != null) {
      await _sendMessageToFirestore(url, 'doc');
      setState(() {
        _selectedFile = null;
        _selectedFileName = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File upload failed')));
    }
  }

  Future<void> _sendAudio() async {
    if (_audioPath == null) return;
    final f = File(_audioPath!);
    if (!f.existsSync()) return;
    final url = await _uploadFileToCloudinary(f, 'video'); // audio use video/upload
    if (url != null) {
      await _sendMessageToFirestore(url, 'audio');
      _deleteRecording();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio upload failed')));
    }
  }

  Widget _buildSelectedPreview() {
    if (_selectedImage != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_selectedImage!, width: 68, height: 68, fit: BoxFit.cover)),
            const SizedBox(width: 10),
            Expanded(child: Text('Image selected', style: const TextStyle(fontWeight: FontWeight.w500))),
            IconButton(onPressed: () => setState(() => _selectedImage = null), icon: const Icon(Icons.close)),
            IconButton(onPressed: () async {
              // open preview
              if (_selectedImage != null) await launchUrl(Uri.file(_selectedImage!.path));
            }, icon: const Icon(Icons.open_in_full)),
            ElevatedButton(onPressed: _busy ? null : _sendSelectedImage, child: const Text('Send'))
          ],
        ),
      );
    } else if (_selectedFile != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 36),
            const SizedBox(width: 10),
            Expanded(child: Text(_selectedFileName ?? 'Document', style: const TextStyle(fontWeight: FontWeight.w500))),
            IconButton(onPressed: () => setState(() { _selectedFile = null; _selectedFileName = null; }), icon: const Icon(Icons.close)),
            IconButton(onPressed: () async {
              if (_selectedFile != null) await launchUrl(Uri.file(_selectedFile!.path));
            }, icon: const Icon(Icons.open_in_full)),
            ElevatedButton(onPressed: _busy ? null : _sendSelectedFile, child: const Text('Send'))
          ],
        ),
      );
    } else if (_audioPath != null) {
      final mm = Duration(seconds: _recSeconds);
      final mmStr = '${mm.inMinutes.remainder(60).toString().padLeft(2,'0')}:${(mm.inSeconds.remainder(60)).toString().padLeft(2,'0')}';
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic, color: Colors.purple),
            const SizedBox(width: 10),
            Expanded(child: Text('Recording • $mmStr', style: const TextStyle(fontWeight: FontWeight.w500))),
            IconButton(onPressed: _deleteRecording, icon: const Icon(Icons.delete)),
            ElevatedButton(onPressed: _busy ? null : _sendAudio, child: const Text('Send'))
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
Widget build(BuildContext context) {
  return Column(
    children: [
      // 🔹 Preview area (image / file / audio)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: _buildSelectedPreview(),
      ),

      // 🔹 Colourful input area
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2EBF2), // soft cyan
              Color(0xFFB3E5FC), // light blue
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 📸 Image picker
            IconButton(
              icon: const Icon(Icons.image, color: Colors.deepPurpleAccent, size: 28),
              onPressed: _pickImage,
            ),

            // 📎 File picker
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.orangeAccent, size: 26),
              onPressed: _pickDocument,
            ),

            // 🎙️ Audio recorder
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                color: _isRecording ? Colors.red : Colors.redAccent,
                size: 27,
              ),
              onPressed: () async {
                if (_isRecording) {
                  await _stopRecording();
                } else {
                  await _startRecordingIfPossible();
                }
              },
            ),

            // ✏️ Message text field
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // 🚀 Send button or loader
            _busy
                ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.deepPurpleAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {
                        if ((_selectedImage != null) ||
                            (_selectedFile != null) ||
                            (_audioPath != null)) {
                          if (_selectedImage != null) _sendSelectedImage();
                          else if (_selectedFile != null) _sendSelectedFile();
                          else if (_audioPath != null) _sendAudio();
                        } else {
                          final t = _textController.text.trim();
                          if (t.isNotEmpty) _sendText();
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    ],
  );
}

  Future<void> _startRecordingIfPossible() async {
    if (!_recorderInited) await _initRecorder();
    final s = await Permission.microphone.request();
    if (!s.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission required')));
      return;
    }
    _startRecording();
  }
}
