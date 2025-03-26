import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatGroup> _groups = [
    ChatGroup(
      id: '1',
      name: 'Product Team',
      code: 'PROD123',
      members: ['John Doe', 'Jane Smith', 'Mike Johnson'],
      messages: [
        Message(
          id: '1',
          sender: 'John Doe',
          content: 'Hey everyone! How\'s the sprint going?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          status: MessageStatus.read,
          reactions: {
            '👍': ['John Doe']
          },
          attachments: [],
        ),
        Message(
          id: '2',
          sender: 'Jane Smith',
          content: 'Great! Just finished the UI updates.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          status: MessageStatus.delivered,
          reactions: {},
          attachments: [],
        ),
      ],
    ),
    ChatGroup(
      id: '2',
      name: 'Design Team',
      code: 'DES456',
      members: ['Jane Smith', 'Sarah Wilson', 'Tom Brown'],
      messages: [
        Message(
          id: '3',
          sender: 'Jane Smith',
          content: 'New design system is ready for review.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: MessageStatus.read,
          reactions: {},
          attachments: [],
        ),
      ],
    ),
  ];

  ChatGroup? _selectedGroup;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _showEmoji = false;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _messagesPerPage = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    // TODO: Implement pagination
    setState(() {
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedGroup == null
            ? const Text('Chat').animate().fadeIn(duration: 300.ms)
            : Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedGroup = null;
                      });
                    },
                  ),
                  Text(_selectedGroup!.name),
                ],
              ),
        actions: [
          if (_selectedGroup == null) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
            ).animate().fadeIn(delay: 100.ms),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateGroupDialog(context),
            ).animate().fadeIn(delay: 200.ms),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showGroupInfo(context),
            ),
          ],
        ],
      ),
      body: _selectedGroup == null
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search groups...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.1, end: 0),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    _showGroupOptions(context, group),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.more_vert,
                                label: 'Options',
                              ),
                              SlidableAction(
                                onPressed: (context) =>
                                    _showLeaveGroupConfirmation(context, group),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.exit_to_app,
                                label: 'Leave',
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                group.name[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(group.name),
                            subtitle: Text('${group.members.length} members'),
                            onTap: () {
                              setState(() {
                                _selectedGroup = group;
                                _currentPage = 1;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showJoinGroupDialog(context),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join Group'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedGroup!.messages.length,
                    itemBuilder: (context, index) {
                      final message = _selectedGroup!.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                // Typing Indicator
                if (_isTyping)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Someone is typing...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_showEmoji)
                        SizedBox(
                          height: 250,
                          child: EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              setState(() {
                                _messageController.text += emoji.emoji;
                                _showEmoji = false;
                              });
                            },
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            onPressed: () {
                              setState(() {
                                _showEmoji = !_showEmoji;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () => _showAttachmentOptions(context),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (value) {
                                // TODO: Implement typing indicator
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender == 'John Doe'; // TODO: Replace with actual user

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Slidable(
        endActionPane: isMe
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) =>
                        _showMessageOptions(context, message),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.more_vert,
                    label: 'Options',
                  ),
                  SlidableAction(
                    onPressed: (context) =>
                        _showDeleteMessageConfirmation(context, message),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              )
            : null,
        child: GestureDetector(
          onLongPress: () => _showMessageOptions(context, message),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message.sender,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                if (message.attachments.isNotEmpty)
                  ...message.attachments
                      .map((attachment) => _buildAttachment(attachment)),
                if (message.reactions.isNotEmpty)
                  _buildReactions(message.reactions),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _getStatusIcon(message.status),
                        size: 12,
                        color: isMe ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: isMe ? 0.2 : -0.2, end: 0, duration: 300.ms)
        .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms);
  }

  Widget _buildAttachment(Attachment attachment) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAttachmentIcon(attachment.type),
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            attachment.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.1, end: 0, duration: 200.ms);
  }

  Widget _buildReactions(Map<String, List<String>> reactions) {
    return Wrap(
      spacing: 4,
      children: reactions.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                entry.value.length.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 200.ms);
      }).toList(),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      default:
        return Icons.access_time;
    }
  }

  IconData _getAttachmentIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return Icons.image;
      case AttachmentType.file:
        return Icons.insert_drive_file;
      case AttachmentType.video:
        return Icons.videocam;
      case AttachmentType.audio:
        return Icons.audiotrack;
      default:
        return Icons.attach_file;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final formatter = DateFormat('MMM d, y HH:mm');

    if (difference.inDays > 7) {
      return formatter.format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      id: const Uuid().v4(),
      sender: 'John Doe', // TODO: Replace with actual user
      content: _messageController.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      reactions: {},
      attachments: [],
    );

    setState(() {
      _selectedGroup!.messages.add(message);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageOptions(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              // TODO: Implement reply
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions_outlined),
            title: const Text('Add Reaction'),
            onTap: () {
              Navigator.pop(context);
              _showReactionPicker(context, message);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              // TODO: Implement copy
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteMessageConfirmation(context, message);
            },
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reaction'),
        content: SizedBox(
          height: 300,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              setState(() {
                final reactions = message.reactions;
                if (reactions.containsKey(emoji.emoji)) {
                  reactions[emoji.emoji]!
                      .add('John Doe'); // TODO: Replace with actual user
                } else {
                  reactions[emoji.emoji] = ['John Doe'];
                }
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteMessageConfirmation(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedGroup!.messages.remove(message);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Image'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Video'),
            onTap: () {
              Navigator.pop(context);
              _pickVideo();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('File'),
            onTap: () {
              Navigator.pop(context);
              _pickFile();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // TODO: Implement image upload
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // TODO: Implement video upload
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // TODO: Implement file upload
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Messages'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search in messages...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // TODO: Implement message search
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement group creation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Group Code',
                hintText: 'Enter group code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement group joining
              Navigator.pop(context);
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(BuildContext context, ChatGroup group) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Group Code'),
            onTap: () {
              // TODO: Implement copy code
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('View Members'),
            onTap: () {
              Navigator.pop(context);
              _showGroupMembers(context, group);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Group Settings'),
            onTap: () {
              // TODO: Implement group settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title:
                const Text('Leave Group', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLeaveGroupConfirmation(context, group);
            },
          ),
        ],
      ),
    );
  }

  void _showGroupInfo(BuildContext context) {
    if (_selectedGroup == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedGroup!.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group Code: ${_selectedGroup!.code}'),
            const SizedBox(height: 16),
            const Text('Members:'),
            ..._selectedGroup!.members.map((member) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(member),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGroupMembers(BuildContext context, ChatGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: group.members
              .map((member) => ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(member),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // TODO: Implement member options
                      },
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupConfirmation(BuildContext context, ChatGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave ${group.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement leave group
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class ChatGroup {
  final String id;
  final String name;
  final String code;
  final List<String> members;
  final List<Message> messages;

  ChatGroup({
    required this.id,
    required this.name,
    required this.code,
    required this.members,
    required this.messages,
  });
}

class Message {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final Map<String, List<String>> reactions;
  final List<Attachment> attachments;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.reactions,
    required this.attachments,
  });
}

enum MessageStatus {
  sent,
  delivered,
  read,
}

class Attachment {
  final String id;
  final String name;
  final String url;
  final AttachmentType type;

  Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
  });
}

enum AttachmentType {
  image,
  video,
  audio,
  file,
}
