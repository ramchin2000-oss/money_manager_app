import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/note_service.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final NoteService noteService = NoteService();
  List<Map<String, dynamic>> notes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    setState(() => isLoading = true);
    try {
      final data = await noteService.findAll();
      setState(() => notes = data);
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void openDetailPage(Map<String, dynamic>? note, {bool isNew = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailPage(
          note: note,
          noteService: noteService,
          isNew: isNew,
          onRefresh: fetchNotes,
        ),
      ),
    );
  }

  String formatTime(String? dateStr) {
    final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
    return DateFormat("hh:mm a").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          notes.isEmpty && !isLoading
              ? const Center(child: Text('No notes found'))
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (_, index) {
                    final note = notes[index];
                    final preview = (note['content'] ?? '').toString();
                    final contentPreview = preview.length > 30
                        ? '${preview.substring(0, 25)} . . .'
                        : preview;
                    final previewTitle = (note['title'] ?? '').toString();
                    final contentPreviewTitle = previewTitle.length > 25
                        ? '${previewTitle.substring(0, 25)} . . .'
                        : previewTitle;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => openDetailPage(note),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Title: $contentPreviewTitle',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Content: $contentPreview',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    formatTime(note['date']),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addNoteBtn",
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () {
          openDetailPage(null, isNew: true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteDetailPage extends StatefulWidget {
  final Map<String, dynamic>? note;
  final NoteService noteService;
  final bool isNew;
  final Function onRefresh;

  const NoteDetailPage({
    super.key,
    required this.note,
    required this.noteService,
    required this.onRefresh,
    this.isNew = false,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?['title'] ?? '');
    contentController = TextEditingController(
      text: widget.note?['content'] ?? '',
    );
  }

  Future<void> saveNote() async {
    setState(() => isSaving = true);
    try {
      if (widget.isNew) {
        await widget.noteService.create(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          userId: 1,
        );
      } else {
        await widget.noteService.update(
          widget.note!['id'],
          title: titleController.text,
          content: contentController.text,
        );
      }
      await widget.onRefresh(); // reload parent list
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving note: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  void confirmDelete() {
    if (widget.note == null || widget.isNew) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              try {
                await widget.noteService.remove(widget.note!['id']);
                await widget.onRefresh();
                Navigator.pop(context); // close detail page
              } catch (e) {
                debugPrint('Error deleting note: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: contentController.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
  }

  @override
  Widget build(BuildContext context) {
    final createdAt =
        DateTime.tryParse(widget.note?['date'] ?? '') ?? DateTime.now();
    final formattedDate = DateFormat("dd MMM yyyy").format(createdAt);
    final formattedTime = DateFormat("hh:mm a").format(createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTES', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.teal,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            tooltip: 'Save',
            onPressed: saveNote,
          ),
          if (!widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Delete',
              onPressed: confirmDelete,
            ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            tooltip: 'Copy',
            onPressed: copyToClipboard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isSaving
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Title",
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "Content:",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Write something...",
                      ),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
