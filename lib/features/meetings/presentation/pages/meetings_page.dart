import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingsPage extends StatelessWidget {
  const MeetingsPage({super.key});

  static final List<Meeting> _meetings = [
    Meeting(
      id: '1',
      title: 'Weekly Team Sync',
      date: DateTime.now().subtract(const Duration(days: 1)),
      actionItems: [
        ActionItem(
          id: '1',
          title: 'Implement dark mode support',
          assignee: 'John Doe',
        ),
        ActionItem(
          id: '2',
          title: 'Review and update documentation',
          assignee: 'Jane Smith',
        ),
      ],
    ),
    Meeting(
      id: '2',
      title: 'Project Planning',
      date: DateTime.now().subtract(const Duration(days: 3)),
      actionItems: [
        ActionItem(
          id: '3',
          title: 'Create project timeline',
          assignee: 'Mike Johnson',
        ),
        ActionItem(
          id: '4',
          title: 'Define MVP features',
          assignee: 'Sarah Wilson',
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
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement new meeting
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return _buildMeetingCard(context, meeting);
        },
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, Meeting meeting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(meeting.title),
            subtitle: Text(
              DateFormat('MMM d, y • h:mm a').format(meeting.date),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Implement meeting options
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Items',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...meeting.actionItems.map((item) => _buildActionItem(item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(ActionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_box_outline_blank, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title),
                if (item.assignee != null)
                  Text(
                    'Assigned to: ${item.assignee}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Meeting {
  final String id;
  final String title;
  final DateTime date;
  final List<ActionItem> actionItems;

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.actionItems,
  });
}

class ActionItem {
  final String id;
  final String title;
  final String? assignee;

  ActionItem({
    required this.id,
    required this.title,
    this.assignee,
  });
}
