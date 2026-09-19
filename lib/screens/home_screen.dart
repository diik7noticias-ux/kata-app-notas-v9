import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'home_screen.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    taskBox = await Hive.openBox<Task>('tasks');
    setState(() {});
  }

  void _addTask(String title) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    taskBox.add(newTask);
    setState(() {});
  }

  void _toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    taskBox.put(task.id, task);
    setState(() {});
  }

  void _deleteTask(String taskId) {
    final task = taskBox.get(taskId);
    if (task != null) {
      taskBox.delete(taskId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas V9'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: taskBox.listenable(),
        builder: (context, box, _) {
          final tasks = box.values.toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => _toggleTaskCompletion(task),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Nova Tarefa'),
                content: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Digite o título da tarefa',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        _addTask(titleController.text);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
