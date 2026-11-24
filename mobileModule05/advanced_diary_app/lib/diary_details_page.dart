import 'dart:developer';
import 'dart:ui';

import 'package:advanced_diary_app/supabase_service.dart';
import 'package:advanced_diary_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:advanced_diary_app/diary.dart';

class DiaryDetailsPage extends StatefulWidget {
  final Diary? diary;

  const DiaryDetailsPage({super.key, required this.diary});

  @override
  State<DiaryDetailsPage> createState() => _DiaryDetailsPageState();
}

class _DiaryDetailsPageState extends State<DiaryDetailsPage> {
  Diary? get diary => widget.diary;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  FeelingType feeling = FeelingType.neutral;
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = diary?.title ?? '';
    _textController.text = diary?.text ?? '';
    feeling = FeelingType.fromIndex(diary?.feeling ?? 0);
    _isEditMode = diary == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !_isEditMode
              ? diary!.getFormattedDate()
              : diary == null
              ? "New Diary"
              : "Edit Diary",
          style: TextStyle(fontWeight: .bold),
        ),
        actions: [
          if (diary != null && !_isEditMode)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: "edit",
                    child: Row(
                      spacing: 2,
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Row(
                      spacing: 2,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                        Text("Delete", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (item) {
                switch (item) {
                  case "edit":
                    _setEditing(!_isEditMode);
                    break;
                  case "delete":
                    _delete();
                    break;

                  default:
                }
              },
            ),
          if (_isEditMode && !_isSaving && !_isDeleting)
            IconButton(
              onPressed: () => _submit(),
              icon: const Icon(
                Icons.check,
                color: Colors.blue,
                fontWeight: .bold,
              ),
            ),
          if (_isSaving || _isDeleting)
            Container(
              width: 20,
              height: 20,
              margin: .only(right: 16),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 12,
            children: [
              TextField(
                controller: _titleController,
                readOnly: !_isEditMode,
                maxLength: 64,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 32,
                  fontWeight: .bold,
                ),
                decoration: InputDecoration(
                  border: .none,
                  hintText: 'Title',
                  counterText: "",
                  hintStyle: TextStyle(color: Colors.blue, fontSize: 32),
                ),
              ),
              Row(
                spacing: 12,
                crossAxisAlignment: .center,
                children: [
                  Text(
                    "My feeling",
                    style: TextStyle(fontSize: 28, fontWeight: .bold),
                  ),
                  _IconPicker(
                    feeling: feeling,
                    readOnly: !_isEditMode,
                    onChanged: (feeling) =>
                        setState(() => this.feeling = feeling!),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: TextField(
                    maxLines: null,
                    keyboardType: .multiline,
                    decoration: InputDecoration(
                      border: .none,
                      hintText: "What is in your mind?",
                    ),
                    controller: _textController,
                    readOnly: !_isEditMode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    try {
      if (title.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
        return;
      }
      if (text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter some text')));
        return;
      }

      _setSaving(true);

      if (_isEditMode && diary != null) {
        await SupabaseService.updateDiary(
          diary!.copyWith(title: title, text: text, feeling: feeling.index),
        );
      } else {
        await SupabaseService.insertDiary(
          Diary(title: title, text: text, feeling: feeling.index),
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      log("DEBUG : $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to save the Diary!")));
    } finally {
      if (mounted) _setSaving(false);
    }
  }

  void _setEditing(bool value) => setState(() => _isEditMode = value);
  void _setSaving(bool value) => setState(() => _isSaving = value);
  void _setDeleting(bool value) => setState(() => _isDeleting = value);

  void _delete() async {
    try {
      _setDeleting(true);
      await SupabaseService.deleteDiary(id: diary!.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      log("DEBUG : $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to delete the Diary!")));
    } finally {
      _setDeleting(false);
    }
  }
}

class _IconPicker extends StatelessWidget {
  final FeelingType feeling;
  final bool readOnly;
  final ValueChanged<FeelingType?> onChanged;
  const _IconPicker({
    required this.feeling,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentIcon = feeling;
    return DropdownButton<FeelingType>(
      padding: .zero,
      value: currentIcon,
      isDense: true,
      icon: SizedBox.shrink(),
      underline: const SizedBox(),
      selectedItemBuilder: readOnly
          ? null
          : (context) {
              return FeelingType.values.map((entry) {
                return Stack(
                  clipBehavior: .none,
                  children: [
                    Icon(entry.icon, size: 32, color: entry.color),
                    if (!readOnly)
                      Positioned(
                        bottom: -10,
                        right: -2,
                        child: Container(
                          padding: .all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit, size: 12, color: Colors.blue),
                        ),
                      ),
                  ],
                );
              }).toList();
            },
      items: FeelingType.values.map((entry) {
        return DropdownMenuItem<FeelingType>(
          value: entry,
          child: Icon(entry.icon, size: 32, color: entry.color),
        );
      }).toList(),
      onChanged: !readOnly ? onChanged : null,
    );
  }
}
