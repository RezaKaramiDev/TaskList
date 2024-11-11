import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasklist/data.dart';
import 'package:tasklist/main.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskEntity task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: widget.task.name);
    final ThemeData themData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style:
              themData.textTheme.headlineLarge!.apply(color: primaryTextColor),
        ),
        backgroundColor: themData.colorScheme.surface,
        foregroundColor: themData.colorScheme.onSurface,
      ),
      backgroundColor: themData.colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            widget.task.name = controller.text;
            widget.task.priority = widget.task.priority;
            if (widget.task.isInBox) {
              widget.task.save();
            } else {
              final box = Hive.box<TaskEntity>(taskBoxName);
              box.add(widget.task);
            }
            Navigator.of(context).pop();
          },
          label: const Row(
            children: [
              Text('Save Changes'),
              SizedBox(
                width: 4,
              ),
              Icon(
                CupertinoIcons.check_mark,
                size: 18,
              )
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                    flex: 1,
                    child: PriorityButton(
                      label: 'High',
                      color: highPriority,
                      isSelected: widget.task.priority == Priority.high,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.high;
                        });
                      },
                    )),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                    flex: 1,
                    child: PriorityButton(
                      label: 'Normal',
                      color: normalPriority,
                      isSelected: widget.task.priority == Priority.normal,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.normal;
                        });
                      },
                    )),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                    flex: 1,
                    child: PriorityButton(
                      label: 'Low',
                      color: lowPriority,
                      isSelected: widget.task.priority == Priority.low,
                      onTap: () {
                        setState(() {
                          widget.task.priority = Priority.low;
                        });
                      },
                    )),
              ],
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                  label: Text(
                'Add a task for today...',
                style: TextStyle(fontSize: 18),
              )),
            )
          ],
        ),
      ),
    );
  }
}

class PriorityButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback onTap;

  const PriorityButton(
      {super.key,
      required this.label,
      required this.color,
      required this.isSelected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                width: 2, color: secondaryTextColor.withOpacity(0.2))),
        child: Stack(children: [
          Center(
            child: Text(
              label,
              style: themeData.textTheme.headlineMedium!
                  .apply(fontSizeFactor: 0.85),
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            right: 8,
            child: Center(
              child: ChekboxShape(
                value: isSelected,
                color: color,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class ChekboxShape extends StatelessWidget {
  final bool value;
  final Color color;

  const ChekboxShape({super.key, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      height: 16,
      width: 16,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              size: 12,
              color: themeData.colorScheme.onPrimary,
            )
          : null,
    );
  }
}
