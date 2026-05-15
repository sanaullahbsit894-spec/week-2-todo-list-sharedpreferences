import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  final StorageService _storage = StorageService();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storage.loadTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.lightImpact();
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmed,
      createdAt: DateTime.now(),
    );
    setState(() => _tasks.insert(0, task));
    await _storage.saveTasks(_tasks);
    _inputController.clear();
  }

  Future<void> _toggleTask(String id) async {
    HapticFeedback.selectionClick();
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
      }
    });
    await _storage.saveTasks(_tasks);
  }

  Future<void> _deleteTask(String id) async {
    HapticFeedback.mediumImpact();
    setState(() => _tasks.removeWhere((t) => t.id == id));
    await _storage.saveTasks(_tasks);
  }

  Future<void> _clearCompleted() async {
    HapticFeedback.heavyImpact();
    setState(() => _tasks.removeWhere((t) => t.isDone));
    await _storage.saveTasks(_tasks);
  }

  int get _completedCount => _tasks.where((t) => t.isDone).length;
  int get _totalCount => _tasks.length;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8FF47);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TASKFLOW',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    letterSpacing: 5,
                    color: const Color(0xFF444444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        _totalCount == 0
                            ? 'Nothing\nyet.'
                            : 'You\'ve got\n$_totalCount task${_totalCount != 1 ? 's' : ''}.',
                        style: GoogleFonts.dmSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF5F5F5),
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (_completedCount > 0)
                      GestureDetector(
                        onTap: _clearCompleted,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Text(
                            'Clear done',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: const Color(0xFF555555),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_totalCount > 0) ...[
                  const SizedBox(height: 16),
                  _ProgressBar(
                    completed: _completedCount,
                    total: _totalCount,
                    accent: accent,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _AddTaskField(
              controller: _inputController,
              focusNode: _focusNode,
              onSubmit: _addTask,
              accent: accent,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? _EmptyState()
                    : _TaskList(
                        tasks: _tasks,
                        onToggle: _toggleTask,
                        onDelete: _deleteTask,
                        accent: accent,
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  final Color accent;

  const _ProgressBar({
    required this.completed,
    required this.total,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: const Color(0xFF1C1C1C),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? const Color(0xFF69FF9A) : accent,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$completed of $total completed',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF444444),
          ),
        ),
      ],
    );
  }
}

class _AddTaskField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmit;
  final Color accent;

  const _AddTaskField({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.add_rounded, color: Color(0xFF444444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: onSubmit,
              style: GoogleFonts.dmSans(
                color: const Color(0xFFF5F5F5),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Add a task...',
                hintStyle: GoogleFonts.dmSans(
                  color: const Color(0xFF333333),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          GestureDetector(
            onTap: () => onSubmit(controller.text),
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Color(0xFF0A0A0A),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final Color accent;

  const _TaskList({
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskItem(
          key: ValueKey(task.id),
          task: task,
          onToggle: () => onToggle(task.id),
          onDelete: () => onDelete(task.id),
          accent: accent,
        );
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Color accent;

  const _TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.transparent,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF2A0A0A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF4A1A1A)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color:
                task.isDone ? const Color(0xFF111111) : const Color(0xFF131313),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: task.isDone
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFF242424),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.isDone ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: task.isDone ? accent : const Color(0xFF333333),
                    width: 1.5,
                  ),
                ),
                child: task.isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Color(0xFF0A0A0A),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: task.isDone
                        ? const Color(0xFF333333)
                        : const Color(0xFFE0E0E0),
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: const Color(0xFF444444),
                  ),
                  child: Text(task.title),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF2A2A2A),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: Color(0xFF333333),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All clear.',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add something above to get started.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }
}
