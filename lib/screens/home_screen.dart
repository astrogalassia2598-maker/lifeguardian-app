import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/deadline_extractor.dart';
import '../models/deadline.dart';
import '../services/calendar_service.dart';
import '../services/ocr_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _extractor = DeadlineExtractor();
  final _calendarService = CalendarService();
  final _ocrService = OcrService();

  List<Deadline> _deadlines = [];
  bool _calendarReady = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initCalendar();
  }

  Future<void> _initCalendar() async {
    final ok = await _calendarService.init();
    setState(() {
      _calendarReady = ok;
    });
  }

  void _onExtract() {
    final text = _controller.text;
    final results =
        _extractor.extract(text, defaultTitle: 'Scadenza da testo');
    setState(() {
      _deadlines = results;
    });
  }

  Future<void> _addAllToCalendar() async {
    if (!_calendarReady) return;
    for (final d in _deadlines) {
      await _calendarService.addDeadline(d);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scadenze aggiunte al calendario')),
      );
    }
  }

  Future<void> _pickImageAndOcr() async {
    setState(() {
      _busy = true;
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked == null) {
        setState(() {
          _busy = false;
        });
        return;
      }
      final file = File(picked.path);
      final text = await _ocrService.recognizeTextFromFile(file);
      _controller.text = text;
      _onExtract();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore OCR: $e')),
        );
      }
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAddToCalendar = _deadlines.isNotEmpty && _calendarReady && !_busy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeGuardian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Incolla il testo di una bolletta/email oppure scatta una foto.',
            ),
            const SizedBox(height: 8),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _pickImageAndOcr,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scatta foto bolletta'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Incolla qui il testo…',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy ? null : _onExtract,
                    child: const Text('Estrai scadenze'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAddToCalendar ? _addAllToCalendar : null,
                    child: const Text('Aggiungi al calendario'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _deadlines.length,
                itemBuilder: (context, index) {
                  final d = _deadlines[index];
                  return ListTile(
                    title: Text(d.title),
                    subtitle: Text(
                      '${d.dueDate}  |  ${d.amount != null ? "${d.amount} €" : "Importo non rilevato"}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
