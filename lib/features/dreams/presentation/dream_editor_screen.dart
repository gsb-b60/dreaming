import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatters.dart';
import '../application/dream_store.dart';
import '../domain/dream.dart';
import '../domain/dream_mood.dart';

class DreamEditorScreen extends StatefulWidget {
  const DreamEditorScreen({super.key, this.dream, this.initialDate});

  final Dream? dream;
  final DateTime? initialDate;

  @override
  State<DreamEditorScreen> createState() => _DreamEditorScreenState();
}

class _DreamEditorScreenState extends State<DreamEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  late DreamMood _mood;
  late DateTime _dateTime;
  late List<String> _tags;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final dream = widget.dream;
    final now = DateTime.now();
    _titleController = TextEditingController(text: dream?.title ?? '');
    _contentController = TextEditingController(text: dream?.content ?? '');
    _mood = dream?.mood ?? DreamMoods.neutral;
    _dateTime = dream?.dreamDateTime ?? widget.initialDate ?? now;
    _tags = [...?dream?.tags];
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existingTags = context.watch<DreamStore>().allTags.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dream == null ? 'Record a dream' : 'Edit dream'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Flying over the ocean',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Add a short title.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                minLines: 8,
                maxLines: 18,
                decoration: const InputDecoration(
                  labelText: 'Dream',
                  alignLabelWithHint: true,
                  hintText: 'Write what you remember...',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Write the dream text.'
                    : null,
              ),
              const SizedBox(height: 20),
              Text('Mood', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mood in DreamMoods.all)
                    ChoiceChip(
                      label: Text(mood.displayName),
                      selected: _mood == mood,
                      onSelected: (_) => setState(() => _mood = mood),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date and time: ${fullDateFormat.format(_dateTime)} at ${timeFormat.format(_dateTime)}',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.event_rounded),
                    label: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Tags', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Add tag',
                        hintText: 'lucid',
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => _addTag(_tagController.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
              if (existingTags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in existingTags.take(24))
                      ActionChip(
                        label: Text('#$tag'),
                        onPressed: () => _addTag(tag),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in _tags)
                    InputChip(
                      label: Text('#$tag'),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag(String raw) {
    final tag = Dream.normalizeTag(raw);
    if (tag.isEmpty) return;
    setState(() {
      if (!_tags.contains(tag)) _tags.add(tag);
      _tagController.clear();
    });
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (pickedTime == null) return;
    setState(() {
      _dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final store = context.read<DreamStore>();
    try {
      if (widget.dream == null) {
        await store.createDream(
          title: _titleController.text,
          content: _contentController.text,
          mood: _mood,
          tags: _tags,
          dreamDateTime: _dateTime,
        );
      } else {
        await store.updateDream(
          widget.dream!.copyWith(
            title: _titleController.text,
            content: _contentController.text,
            mood: _mood,
            tags: _tags,
            dreamDateTime: _dateTime,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this dream.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
