import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/data_providers.dart';
import '../../models/app_models.dart';

class GroupTasksView extends ConsumerStatefulWidget {
  final int groupId;
  final String groupName;
  final int projectId;

  const GroupTasksView({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.projectId,
  });

  @override
  ConsumerState<GroupTasksView> createState() => _GroupTasksViewState();
}

class _GroupTasksViewState extends ConsumerState<GroupTasksView> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Tasks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks found in this group.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task, context);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTaskSheet(
        projectId: widget.projectId,
        groupId: widget.groupId,
        onTaskAdded: () {
          ref.invalidate(tasksProvider(widget.groupId));
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (task.status) {
      case 'done':
        statusColor = Colors.green;
        statusLabel = 'Done';
        break;
      case 'inprogress':
        statusColor = Colors.blue;
        statusLabel = 'In Progress';
        break;
      case 'pending':
        statusColor = Colors.amber;
        statusLabel = 'Pending';
        break;
      case 'edit':
        statusColor = Colors.orange;
        statusLabel = 'Needs Revision';
        break;
      case 'approve':
        statusColor = Colors.purple;
        statusLabel = 'Approve';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = task.status;
    }

    Color importanceColor;
    switch (task.importanceStatus) {
      case 'urgent':
        importanceColor = Colors.red;
        break;
      case 'high':
        importanceColor = Colors.orange;
        break;
      case 'medium':
        importanceColor = Colors.blue;
        break;
      case 'low':
      default:
        importanceColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.status == 'done' ? Theme.of(context).cardColor.withOpacity(0.7) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: task.status == 'done' ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: importanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: importanceColor.withOpacity(0.5)),
                ),
                child: Text(
                  task.importanceStatus.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: importanceColor),
                ),
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text(
                    task.deliveryDate != null ? _formatDate(task.deliveryDate!) : 'Not Set',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          if (task.userName != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: task.userImage != null ? NetworkImage(task.userImage!) : null,
                  child: task.userImage == null
                      ? Text(
                          task.userName![0].toUpperCase(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  task.userName!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  final int projectId;
  final int groupId;
  final VoidCallback onTaskAdded;

  const _AddTaskSheet({required this.projectId, required this.groupId, required this.onTaskAdded});

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _importance = 'medium';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final api = ref.read(apiServiceProvider);
      await api.dio.post('/api/admin/tasks', data: {
        'name': _name,
        'description': _description,
        'importanc_status': _importance,
        'status': 'pending',
        'project_id': widget.projectId,
        'group_id': widget.groupId,
        // Engineer adding a task defaults to themselves or unassigned based on backend logic.
      });
      
      widget.onTaskAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _importance,
                decoration: InputDecoration(
                  labelText: 'Importance',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (val) => setState(() => _importance = val!),
                onSaved: (val) => _importance = val!,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
