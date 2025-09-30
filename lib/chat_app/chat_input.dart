import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatInput({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  void _initRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  @override
  void dispose() {
    _controller.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  void sendTextMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          "text": text,
          "type": "text",
          "senderId": widget.currentUserId,
          "timestamp": FieldValue.serverTimestamp(),
        });

    _controller.clear();
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final ref = FirebaseStorage.instance.ref().child(
      'chat_files/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}',
    );
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          "type": "image",
          "url": url,
          "senderId": widget.currentUserId,
          "timestamp": FieldValue.serverTimestamp(),
        });
  }

  Future<void> sendDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'],
    );

    if (result == null) return;
    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    final ref = FirebaseStorage.instance.ref().child(
      'chat_files/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          "type": "document",
          "url": url,
          "name": fileName,
          "senderId": widget.currentUserId,
          "timestamp": FieldValue.serverTimestamp(),
        });
  }

  Future<void> sendVoiceMessage() async {
    if (!_isRecording) {
      final tempPath = '/${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: tempPath);
      setState(() => _isRecording = true);
    } else {
      final path = await _recorder.stopRecorder();
      setState(() => _isRecording = false);

      final file = File(path!);
      final ref = FirebaseStorage.instance.ref().child(
        'chat_files/${DateTime.now().millisecondsSinceEpoch}_voice.aac',
      );
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            "type": "voice",
            "url": url,
            "senderId": widget.currentUserId,
            "timestamp": FieldValue.serverTimestamp(),
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.green),
            onPressed: sendImage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.orange),
            onPressed: sendDocument,
          ),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              color: Colors.red,
            ),
            onPressed: sendVoiceMessage,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: sendTextMessage,
          ),
        ],
      ),
    );
  }
}
