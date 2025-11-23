import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';

class EventFormScreen extends StatefulWidget {
  final String type; // "event" or "tournament"
  final ChessEvent? existing;

  const EventFormScreen({
    super.key,
    required this.type,
    this.existing,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _startTime = DateTime.now().add(const Duration(hours: 2));
  bool _isOnline = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _locationCtrl.text = e.location;
      _descriptionCtrl.text = e.description;
      _startTime = e.startTime;
      _isOnline = e.isOnline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time == null) return;
    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final service = FirestoreService();

    try {
      if (widget.existing == null) {
        await service.createEvent(
          title: _titleCtrl.text.trim(),
          type: widget.type,
          startTime: _startTime,
          location: _locationCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          isOnline: _isOnline,
        );
      } else {
        final updated = ChessEvent(
          id: widget.existing!.id,
          title: _titleCtrl.text.trim(),
          type: widget.existing!.type,
          startTime: _startTime,
          location: _locationCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          isOnline: _isOnline,
          rsvpNames: widget.existing!.rsvpNames,
        );
        await service.updateEvent(updated);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final titleText = isEditing
        ? 'Edit ${widget.type == 'tournament' ? 'tournament' : 'event'}'
        : 'New ${widget.type == 'tournament' ? 'tournament' : 'event'}';

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter a location' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Starts: ${_startTime.year}-${_startTime.month.toString().padLeft(2, '0')}-${_startTime.day.toString().padLeft(2, '0')} '
                        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Change'),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Online event'),
                value: _isOnline,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
