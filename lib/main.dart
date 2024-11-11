// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasklist/data.dart';
import 'package:tasklist/edit.dart';

const taskBoxName = 'task';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794CFF);
const Color primaryVariantColor = Color(0xff5C0AFF);
const Color primaryTextColor = Color(0xff1D2830);
const Color secondaryTextColor = Color(0xffAFBED0);
const Color highPriority = primaryColor;
const Color normalPriority = Color(0xffF09819);
const Color lowPriority = Color(0xff3be1f1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: TextTheme(
            headlineLarge: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary),
            headlineMedium:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            headlineSmall:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: EdgeInsets.only(bottom: 19)),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          inversePrimary: primaryVariantColor,
          onPrimary: Colors.white,
          background: Color(0xffF3F5F8),
          onBackground: primaryTextColor,
          onSurface: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                      task: TaskEntity(),
                    )));
          },
          label: const Row(
            children: [
              Text('Add New Task'),
              SizedBox(
                width: 4,
              ),
              Icon(CupertinoIcons.add)
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [primaryColor, primaryVariantColor])),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'To Do List',
                        style: themeData.textTheme.headlineLarge,
                      ),
                      Icon(
                        CupertinoIcons.rosette,
                        color: themeData.colorScheme.onPrimary,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                        color: themeData.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20)
                        ]),
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        searchKeywordNotifier.value = controller.text;
                      },
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          label: Text('Search Tasks...')),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: ValueListenableBuilder(
                    valueListenable: searchKeywordNotifier,
                    builder: ((context, value, child) {
                      return ValueListenableBuilder(
                          valueListenable: box.listenable(),
                          builder: (context, box, child) {
                            final List<TaskEntity> items;
                            if (controller.text.isEmpty) {
                              items = box.values.toList();
                            } else {
                              items = box.values
                                  .where((task) => task.name
                                      .toLowerCase()
                                      .contains(controller.text.toLowerCase()))
                                  .toList();
                            }
                            if (items.isNotEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                child: ListView.builder(
                                    padding: EdgeInsets.only(bottom: 85),
                                    itemCount: items.length + 1,
                                    itemBuilder: ((context, index) {
                                      if (index == 0) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Today',
                                                  style: themeData
                                                      .textTheme.headlineMedium,
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                Container(
                                                  height: 4,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      color: themeData
                                                          .colorScheme.primary),
                                                )
                                              ],
                                            ),
                                            MaterialButton(
                                              color: const Color(0xffEAEFF5),
                                              elevation: 0,
                                              onPressed: () {
                                                box.clear();
                                              },
                                              child: const Row(
                                                children: [
                                                  Text(
                                                    'Delete All',
                                                    style: TextStyle(
                                                        color:
                                                            secondaryTextColor),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4, bottom: 6),
                                                    child: Icon(
                                                      CupertinoIcons.delete,
                                                      size: 20,
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      } else {
                                        final TaskEntity task =
                                            items.toList()[index - 1];
                                        return TaskItem(task: task);
                                      }
                                    })),
                              );
                            } else {
                              return const EmptyState();
                            }
                          });
                    }))),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/empty_state.svg',
          width: 300,
        ),
        const SizedBox(
          height: 16,
        ),
        const Text(
          'Your task list is empty...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double borderRadius = 8;
  static const double taskHeight = 75;
  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.high:
        priorityColor = highPriority;
        break;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => EditTaskScreen(task: widget.task))));
      },
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
          height: TaskItem.taskHeight,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.only(
            left: 16,
          ),
          decoration: BoxDecoration(
              color: themeData.colorScheme.surface,
              borderRadius: BorderRadius.circular(TaskItem.borderRadius)),
          child: Row(
            children: [
              MyCheckBox(
                value: widget.task.isCompleted,
                onTap: () {
                  setState(() {
                    widget.task.isCompleted = !widget.task.isCompleted;
                  });
                },
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  widget.task.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      decoration: widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : null),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 8,
                height: TaskItem.taskHeight,
                decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(TaskItem.borderRadius),
                        bottomRight: Radius.circular(TaskItem.borderRadius))),
              )
            ],
          )),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;
  final GestureTapCallback onTap;

  const MyCheckBox({super.key, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 26,
        width: 26,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border:
                !value ? Border.all(width: 3, color: secondaryTextColor) : null,
            color: value ? themeData.colorScheme.primary : null),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                size: 16,
                color: themeData.colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }
}
