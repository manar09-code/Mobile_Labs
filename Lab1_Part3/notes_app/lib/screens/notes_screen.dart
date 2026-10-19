import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/auth_provider.dart';
import '../services/notes_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_input_dialog.dart';
import '../widgets/note_item.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final String _userId = context.read<AuthProvider>().user!.$id;
  List<Note> _notes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notes = await notesService.list();
      if (!mounted) return;
      setState(() => _notes = notes);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AppwriteException
            ? error.message ?? 'Could not load notes'
            : error.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add() async {
    final draft = await showNoteInputDialog(context);
    if (draft == null) return;
    try {
      final created = await notesService.create(_userId, draft);
      if (!mounted) return;
      setState(() => _notes.insert(0, created));
    } catch (error) {
      _showError(
        error is AppwriteException
            ? error.message ?? 'Could not save the note'
            : error.toString(),
      );
    }
  }

  Future<void> _edit(Note note) async {
    final draft = await showNoteInputDialog(context, initial: note);
    if (draft == null) return;
    try {
      final updated = await notesService.update(note.id, draft);
      if (!mounted) return;
      setState(() {
        final index = _notes.indexWhere((item) => item.id == note.id);
        if (index >= 0) _notes[index] = updated;
      });
    } catch (error) {
      _showError(
        error is AppwriteException
            ? error.message ?? 'Could not update the note'
            : error.toString(),
      );
    }
  }

  Future<void> _delete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note'),
        content: Text('Delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await notesService.delete(note.id);
      if (!mounted) return;
      setState(() => _notes.removeWhere((item) => item.id == note.id));
    } catch (error) {
      _showError(
        error is AppwriteException
            ? error.message ?? 'Could not delete the note'
            : error.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading && _notes.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: _notes.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [EmptyState(onCreate: _add)],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return NoteItem(
                    key: ValueKey(note.id),
                    note: note,
                    onEdit: () => _edit(note),
                    onDelete: () => _delete(note),
                  );
                },
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
