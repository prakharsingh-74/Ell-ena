import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  final List<Meeting> _meetings = [
    Meeting(
      id: '1',
      title: 'Product Review',
      date: DateTime.now().add(const Duration(days: 1)),
      time: '10:00 AM',
      participants: ['John Doe', 'Jane Smith', 'Mike Johnson'],
      actionItems: [
        ActionItem(
          id: '1',
          title: 'Review Q1 goals',
          assignee: 'John Doe',
          dueDate: DateTime.now().add(const Duration(days: 2)),
        ),
        ActionItem(
          id: '2',
          title: 'Discuss roadmap',
          assignee: 'Jane Smith',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      ],
    ),
    Meeting(
      id: '2',
      title: 'Team Sync',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '2:00 PM',
      participants: ['John Doe', 'Jane Smith'],
      actionItems: [
        ActionItem(
          id: '3',
          title: 'Update sprint status',
          assignee: 'Mike Johnson',
          dueDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return _buildMeetingCard(meeting);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeetingDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    final daysUntil = meeting.date.difference(DateTime.now()).inDays;
    final formattedDate = DateFormat('MMM dd, yyyy').format(meeting.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              meeting.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meeting.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meeting.participants.length} participants',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildDaysUntilChip(daysUntil),
          ),
          if (meeting.actionItems.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Action Items',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...meeting.actionItems.map((item) => _buildActionItem(item)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaysUntilChip(int days) {
    Color color;
    String text;

    if (days < 0) {
      color = Colors.red;
      text = 'Past';
    } else if (days == 0) {
      color = Colors.orange;
      text = 'Today';
    } else if (days == 1) {
      color = Colors.blue;
      text = 'Tomorrow';
    } else {
      color = Colors.green;
      text = '$days days';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionItem(ActionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Assigned to ${item.assignee} • Due ${DateFormat('MMM dd').format(item.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMeetingDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final participantsController = TextEditingController();
    final actionItemsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Schedule New Meeting'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Title',
                    hintText: 'Enter meeting title',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: participantsController,
                  decoration: const InputDecoration(
                    labelText: 'Participants',
                    hintText: 'Enter participant emails (comma-separated)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: actionItemsController,
                  decoration: const InputDecoration(
                    labelText: 'Action Items',
                    hintText: 'Enter action items (one per line)',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement meeting creation
                Navigator.pop(context);
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class Meeting {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final List<String> participants;
  final List<ActionItem> actionItems;

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.participants,
    required this.actionItems,
  });
}

class ActionItem {
  final String id;
  final String title;
  final String assignee;
  final DateTime dueDate;

  ActionItem({
    required this.id,
    required this.title,
    required this.assignee,
    required this.dueDate,
  });
}
