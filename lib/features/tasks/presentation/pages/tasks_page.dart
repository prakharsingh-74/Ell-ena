import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'To Do',
    'In Progress',
    'Done',
    'Overdue'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedFilter = _filters[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _filters.map((filter) => Tab(text: filter)).toList(),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  _filters.map((filter) => _buildTaskList(filter)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(String filter) {
    final filteredTasks = _getFilteredTasks(filter);

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new task to get started',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    _showEditTaskDialog(task);
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (context) {
                    _deleteTask(task);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: Card(
              child: ListTile(
                leading: Checkbox(
                  value: task['status'] == 'Done',
                  onChanged: (bool? value) {
                    _updateTaskStatus(task, value ?? false);
                  },
                ),
                title: Text(
                  task['title'],
                  style: TextStyle(
                    decoration: task['status'] == 'Done'
                        ? TextDecoration.lineThrough
                        : null,
                    color: task['status'] == 'Done' ? Colors.grey : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['description']),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task['dueDate'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task['assignee'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: _buildPriorityChip(task['priority']),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTasks(String filter) {
    // TODO: Implement actual task filtering logic
    return [
      {
        'id': const Uuid().v4(),
        'title': 'Design new UI components',
        'description': 'Create new UI components for the dashboard',
        'status': 'To Do',
        'priority': 'High',
        'dueDate': '2024-03-20',
        'assignee': 'John Doe',
      },
      {
        'id': const Uuid().v4(),
        'title': 'Implement authentication',
        'description': 'Add user authentication and authorization',
        'status': 'In Progress',
        'priority': 'Medium',
        'dueDate': '2024-03-22',
        'assignee': 'Jane Smith',
      },
      {
        'id': const Uuid().v4(),
        'title': 'Write documentation',
        'description': 'Document the API endpoints and usage',
        'status': 'Done',
        'priority': 'Low',
        'dueDate': '2024-03-18',
        'assignee': 'Mike Johnson',
      },
    ].where((task) {
      if (filter == 'All') return true;
      return task['status'] == filter;
    }).toList();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                items: ['High', 'Medium', 'Low']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                  hintText: 'Enter assignee name',
                ),
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
              // TODO: Implement task creation
              Navigator.pop(context);
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    // TODO: Implement edit task dialog
  }

  void _deleteTask(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement task deletion
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

  void _updateTaskStatus(Map<String, dynamic> task, bool isDone) {
    // TODO: Implement task status update
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Show Completed'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement filter logic
                },
              ),
            ),
            ListTile(
              title: const Text('Show Overdue'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement filter logic
                },
              ),
            ),
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
}

class TaskSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  TaskSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    // TODO: Implement search results
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) => const ListTile(),
    );
  }
}
