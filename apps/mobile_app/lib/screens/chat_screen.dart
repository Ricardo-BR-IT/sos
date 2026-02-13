import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sos_kernel/sos_kernel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final MeshService mesh;
  final String targetId;
  final String targetName;

  const ChatScreen({
    Key? key,
    required this.mesh,
    required this.targetId,
    this.targetName = "Peer",
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<SosEnvelope> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _tacticalMode = false;

  final List<String> _quickPhrases = [
    "SOS Medical",
    "Need Evacuation",
    "Supplies Needed",
    "Status OK",
    "Moving to waypoint",
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    widget.mesh.messages.listen((msg) {
      if (!mounted) return;
      if (msg.sender == widget.targetId) {
        setState(() {
          _messages.insert(0, msg);
        });
      }
    });
  }

  Future<void> _handleSendText([String? text]) async {
    final content = text ?? _textController.text.trim();
    if (content.isEmpty) return;

    if (text == null) _textController.clear();
    await _sendMessage(type: 'text', payload: {'content': content});
  }

  Future<void> _handleSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.length > 1024 * 1024) {
        // 1MB Limit
        bool confirm = await _showSizeWarning(bytes.length);
        if (!confirm) return;
      }

      final base64String = base64Encode(bytes);
      await _sendMessage(type: 'image', payload: {
        'content': base64String,
        'mime': 'image/jpeg',
        'name': image.name,
      });
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _handleSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      final file = result.files.single;
      final bytes = file.bytes ??
          (file.path != null ? await File(file.path!).readAsBytes() : null);

      if (bytes == null) return;

      if (bytes.length > 1024 * 1024) {
        // 1MB Limit
        bool confirm = await _showSizeWarning(bytes.length);
        if (!confirm) return;
      }

      final base64String = base64Encode(bytes);
      await _sendMessage(type: 'file', payload: {
        'content': base64String,
        'mime': 'application/octet-stream',
        'name': file.name,
      });
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<bool> _showSizeWarning(int size) async {
    final mb = (size / (1024 * 1024)).toStringAsFixed(2);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Large File Warning'),
            content: Text(
                'This file is $mb MB. Sending large files may congest the mesh network. Continue?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Send Anyway')),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _sendMessage(
      {required String type, required Map<String, dynamic> payload}) async {
    payload['ts'] = DateTime.now().millisecondsSinceEpoch;

    await widget.mesh.sendDirect(
      targetId: widget.targetId,
      type: type,
      payload: payload,
    );

    final myMsg = SosEnvelope(
      version: 1,
      sender: widget.mesh.core.publicKey,
      type: type,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      signature: 'local',
    );

    setState(() {
      _messages.insert(0, myMsg);
    });
  }

  Widget _buildMessageItem(SosEnvelope msg) {
    final isMe = msg.sender == widget.mesh.core.publicKey;
    final content = msg.payload['content'] as String? ?? '';
    final type = msg.type;

    final bubbleColor = _tacticalMode
        ? (isMe ? Colors.red[900] : Colors.grey[900])
        : (isMe ? Colors.cyanAccent : Colors.grey[800]);
    final textColor =
        _tacticalMode ? Colors.redAccent : (isMe ? Colors.black : Colors.white);

    Widget body;
    if (type == 'text') {
      body = Text(content, style: TextStyle(color: textColor));
    } else if (type == 'image') {
      try {
        final bytes = base64Decode(content);
        body = Image.memory(bytes,
            height: 150,
            fit: BoxFit.cover,
            color: _tacticalMode ? Colors.red : null,
            colorBlendMode: _tacticalMode ? BlendMode.multiply : null);
      } catch (e) {
        body = const Text('Invalid Image');
      }
    } else if (type == 'file') {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, color: textColor),
          const SizedBox(width: 8),
          Flexible(
              child: Text(msg.payload['name'] ?? 'File',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor))),
        ],
      );
    } else {
      body = Text('Unknown type: $type', style: TextStyle(color: textColor));
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          border: _tacticalMode ? Border.all(color: Colors.red[900]!) : null,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            body,
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm')
                  .format(DateTime.fromMillisecondsSinceEpoch(msg.timestamp)),
              style: TextStyle(
                  fontSize: 10,
                  color: _tacticalMode
                      ? Colors.red[200]
                      : (isMe ? Colors.black54 : Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _tacticalMode ? Colors.black : null;
    final appBarColor = _tacticalMode ? Colors.black : null;
    final fgColor = _tacticalMode ? Colors.red : null;

    return Theme(
      data: _tacticalMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black, foregroundColor: Colors.red),
              colorScheme: const ColorScheme.dark(
                  primary: Colors.red, secondary: Colors.redAccent),
              iconTheme: const IconThemeData(color: Colors.red),
              textTheme:
                  const TextTheme(bodyMedium: TextStyle(color: Colors.red)),
            )
          : Theme.of(context),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          foregroundColor: fgColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.targetName),
              Text(widget.targetId.substring(0, 8),
                  style: TextStyle(
                      fontSize: 10,
                      color: _tacticalMode ? Colors.red[700] : Colors.grey)),
            ],
          ),
          actions: [
            IconButton(
              icon:
                  Icon(_tacticalMode ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: () => setState(() => _tacticalMode = !_tacticalMode),
              tooltip: 'Tactical Mode',
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.flash_on,
                  color: _tacticalMode ? Colors.red : null),
              onSelected: _handleSendText,
              itemBuilder: (BuildContext context) {
                return _quickPhrases.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text('Secure Mesh Channel\nSay Hello!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _tacticalMode
                                  ? Colors.red[900]
                                  : Colors.grey)))
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) =>
                          _buildMessageItem(_messages[index]),
                    ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: _tacticalMode ? Colors.black : Colors.black12,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo_camera,
                        color: _tacticalMode ? Colors.red : null),
                    onPressed: _handleSendImage,
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file,
                        color: _tacticalMode ? Colors.red : null),
                    onPressed: _handleSendFile,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style:
                          TextStyle(color: _tacticalMode ? Colors.red : null),
                      decoration: InputDecoration(
                        hintText: 'Type secure message...',
                        hintStyle: TextStyle(
                            color: _tacticalMode ? Colors.red[900] : null),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _handleSendText(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: _tacticalMode ? Colors.red : Colors.cyanAccent),
                    onPressed: () => _handleSendText(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
